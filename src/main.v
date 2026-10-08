// VIStra-Accel
// Pipelined INT8 3x3 Convolution Accelerator
// 9 parallel multipliers + adder tree + bias + ReLU

module vistra_conv3x3 (

    input wire clk,
    input wire rst_n,
    input wire valid_in,

    // 9 Pixels
    input signed [7:0] p0,
    input signed [7:0] p1,
    input signed [7:0] p2,
    input signed [7:0] p3,
    input signed [7:0] p4,
    input signed [7:0] p5,
    input signed [7:0] p6,
    input signed [7:0] p7,
    input signed [7:0] p8,

    // 9 Weights
    input signed [7:0] w0,
    input signed [7:0] w1,
    input signed [7:0] w2,
    input signed [7:0] w3,
    input signed [7:0] w4,
    input signed [7:0] w5,
    input signed [7:0] w6,
    input signed [7:0] w7,
    input signed [7:0] w8,

    input signed [31:0] bias,

    output reg signed [31:0] conv_result,
    output reg signed [31:0] relu_result,
    output reg valid_out
);

    // ========================================
    // PIPELINE STAGE 1
    // 9 Parallel Multiplications
    // ========================================

    reg signed [31:0] m0_r;
    reg signed [31:0] m1_r;
    reg signed [31:0] m2_r;
    reg signed [31:0] m3_r;
    reg signed [31:0] m4_r;
    reg signed [31:0] m5_r;
    reg signed [31:0] m6_r;
    reg signed [31:0] m7_r;
    reg signed [31:0] m8_r;

    reg signed [31:0] bias_s1;

    reg valid_s1;

    // ========================================
    // PIPELINE STAGE 2
    // First adder level
    // ========================================

    reg signed [31:0] sum01_r;
    reg signed [31:0] sum23_r;
    reg signed [31:0] sum45_r;
    reg signed [31:0] sum67_r;

    reg signed [31:0] m8_s2;
    reg signed [31:0] bias_s2;

    reg valid_s2;

    // ========================================
    // PIPELINE STAGE 3
    // Second adder level
    // ========================================

    reg signed [31:0] sum0123_r;
    reg signed [31:0] sum4567_r;
    reg signed [31:0] tail_r;

    reg valid_s3;

    // ========================================
    // PIPELINE STAGE 4
    // Combine first 8 MAC results
    // ========================================

    reg signed [31:0] sum0to7_r;
    reg signed [31:0] tail_s4;

    reg valid_s4;

    // Final combinational result before register
    wire signed [31:0] final_sum;

    assign final_sum = sum0to7_r + tail_s4;

    // ========================================
    // PIPELINE PROCESS
    // ========================================

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            m0_r <= 0;
            m1_r <= 0;
            m2_r <= 0;
            m3_r <= 0;
            m4_r <= 0;
            m5_r <= 0;
            m6_r <= 0;
            m7_r <= 0;
            m8_r <= 0;

            bias_s1 <= 0;

            sum01_r <= 0;
            sum23_r <= 0;
            sum45_r <= 0;
            sum67_r <= 0;

            m8_s2 <= 0;
            bias_s2 <= 0;

            sum0123_r <= 0;
            sum4567_r <= 0;
            tail_r <= 0;

            sum0to7_r <= 0;
            tail_s4 <= 0;

            conv_result <= 0;
            relu_result <= 0;

            valid_s1 <= 0;
            valid_s2 <= 0;
            valid_s3 <= 0;
            valid_s4 <= 0;
            valid_out <= 0;

        end else begin

            // =================================
            // STAGE 1
            // =================================

            m0_r <= p0 * w0;
            m1_r <= p1 * w1;
            m2_r <= p2 * w2;
            m3_r <= p3 * w3;
            m4_r <= p4 * w4;
            m5_r <= p5 * w5;
            m6_r <= p6 * w6;
            m7_r <= p7 * w7;
            m8_r <= p8 * w8;

            bias_s1 <= bias;

            valid_s1 <= valid_in;


            // =================================
            // STAGE 2
            // =================================

            sum01_r <= m0_r + m1_r;
            sum23_r <= m2_r + m3_r;
            sum45_r <= m4_r + m5_r;
            sum67_r <= m6_r + m7_r;

            m8_s2 <= m8_r;
            bias_s2 <= bias_s1;

            valid_s2 <= valid_s1;


            // =================================
            // STAGE 3
            // =================================

            sum0123_r <= sum01_r + sum23_r;
            sum4567_r <= sum45_r + sum67_r;

            // pixel 8 result + bias
            tail_r <= m8_s2 + bias_s2;

            valid_s3 <= valid_s2;


            // =================================
            // STAGE 4
            // =================================

            sum0to7_r <= sum0123_r + sum4567_r;

            tail_s4 <= tail_r;

            valid_s4 <= valid_s3;


            // =================================
            // STAGE 5
            // Final result + ReLU
            // =================================

            conv_result <= final_sum;

            if (final_sum[31])
                relu_result <= 32'sd0;
            else
                relu_result <= final_sum;

            valid_out <= valid_s4;

        end

    end

endmodule

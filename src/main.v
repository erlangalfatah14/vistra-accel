// VIStra-Accel
// 3x3 Convolution Accelerator
// INT8 pixels and INT8 weights

module vistra_conv3x3 (

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

    output signed [31:0] conv_result,
    output signed [31:0] relu_result
);

    wire signed [31:0] m0;
    wire signed [31:0] m1;
    wire signed [31:0] m2;
    wire signed [31:0] m3;
    wire signed [31:0] m4;
    wire signed [31:0] m5;
    wire signed [31:0] m6;
    wire signed [31:0] m7;
    wire signed [31:0] m8;

    // 9 parallel multiplications
    assign m0 = p0 * w0;
    assign m1 = p1 * w1;
    assign m2 = p2 * w2;
    assign m3 = p3 * w3;
    assign m4 = p4 * w4;
    assign m5 = p5 * w5;
    assign m6 = p6 * w6;
    assign m7 = p7 * w7;
    assign m8 = p8 * w8;

    // Convolution sum
    assign conv_result =
        m0 + m1 + m2 +
        m3 + m4 + m5 +
        m6 + m7 + m8 +
        bias;

    // ReLU
    // conv_result[31] = 1 berarti nilai negatif
    assign relu_result =
        conv_result[31] ? 32'sd0 : conv_result;

endmodule

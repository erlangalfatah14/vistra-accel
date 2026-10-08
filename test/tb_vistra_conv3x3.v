`timescale 1ns/1ps

module tb_vistra_conv3x3;

    reg signed [7:0] p0,p1,p2,p3,p4,p5,p6,p7,p8;
    reg signed [7:0] w0,w1,w2,w3,w4,w5,w6,w7,w8;

    reg signed [31:0] bias;

    wire signed [31:0] conv_result;
    wire signed [31:0] relu_result;

    vistra_conv3x3 dut (

        .p0(p0), .p1(p1), .p2(p2),
        .p3(p3), .p4(p4), .p5(p5),
        .p6(p6), .p7(p7), .p8(p8),

        .w0(w0), .w1(w1), .w2(w2),
        .w3(w3), .w4(w4), .w5(w5),
        .w6(w6), .w7(w7), .w8(w8),

        .bias(bias),

        .conv_result(conv_result),
        .relu_result(relu_result)
    );

    initial begin

        // =====================================
        // TEST 1
        // =====================================

        p0=1; p1=2; p2=3;
        p3=4; p4=5; p5=6;
        p6=7; p7=8; p8=9;

        // Semua weight = 1
        w0=1; w1=1; w2=1;
        w3=1; w4=1; w5=1;
        w6=1; w7=1; w8=1;

        bias = 0;

        #10;

        $display("TEST 1");
        $display("Conv Result = %d", conv_result);
        $display("ReLU Result = %d", relu_result);

        // Expected:
        // 1+2+3+4+5+6+7+8+9 = 45


        // =====================================
        // TEST 2 - Negative result / ReLU
        // =====================================

        w0=-1; w1=-1; w2=-1;
        w3=-1; w4=-1; w5=-1;
        w6=-1; w7=-1; w8=-1;

        bias = 0;

        #10;

        $display("TEST 2");
        $display("Conv Result = %d", conv_result);
        $display("ReLU Result = %d", relu_result);

        // Expected:
        // Conv = -45
        // ReLU = 0


        $finish;

    end

endmodule

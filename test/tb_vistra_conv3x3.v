`timescale 1ns/1ps

module tb_vistra_conv3x3;

    reg clk;
    reg rst_n;
    reg valid_in;

    reg signed [7:0] p0,p1,p2,p3,p4,p5,p6,p7,p8;
    reg signed [7:0] w0,w1,w2,w3,w4,w5,w6,w7,w8;

    reg signed [31:0] bias;

    wire signed [31:0] conv_result;
    wire signed [31:0] relu_result;

    wire valid_out;


    vistra_conv3x3 dut (

        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),

        .p0(p0), .p1(p1), .p2(p2),
        .p3(p3), .p4(p4), .p5(p5),
        .p6(p6), .p7(p7), .p8(p8),

        .w0(w0), .w1(w1), .w2(w2),
        .w3(w3), .w4(w4), .w5(w5),
        .w6(w6), .w7(w7), .w8(w8),

        .bias(bias),

        .conv_result(conv_result),
        .relu_result(relu_result),
        .valid_out(valid_out)

    );


    // 100 MHz simulation clock
    // period = 10 ns
    always #5 clk = ~clk;


    initial begin

        clk = 0;
        rst_n = 0;
        valid_in = 0;

        p0 = 0; p1 = 0; p2 = 0;
        p3 = 0; p4 = 0; p5 = 0;
        p6 = 0; p7 = 0; p8 = 0;

        w0 = 0; w1 = 0; w2 = 0;
        w3 = 0; w4 = 0; w5 = 0;
        w6 = 0; w7 = 0; w8 = 0;

        bias = 0;


        // Reset
        #20;
        rst_n = 1;


        // =====================================
        // TEST 1
        // Expected convolution = 45
        // Expected ReLU = 45
        // =====================================

        @(negedge clk);

        p0=1; p1=2; p2=3;
        p3=4; p4=5; p5=6;
        p6=7; p7=8; p8=9;

        w0=1; w1=1; w2=1;
        w3=1; w4=1; w5=1;
        w6=1; w7=1; w8=1;

        bias = 0;

        valid_in = 1;

        @(negedge clk);
        valid_in = 0;


        // Wait for pipeline result
        wait(valid_out == 1);

        #1;

        $display("==============================");
        $display("TEST 1");
        $display("Conv Result = %d", conv_result);
        $display("ReLU Result = %d", relu_result);

        if (conv_result == 45 &&
            relu_result == 45)
            $display("TEST 1 PASSED");
        else
            $display("TEST 1 FAILED");

        $display("==============================");


        // Wait until valid_out drops
        @(negedge clk);


        // =====================================
        // TEST 2
        // Expected convolution = -45
        // Expected ReLU = 0
        // =====================================

        p0=1; p1=2; p2=3;
        p3=4; p4=5; p5=6;
        p6=7; p7=8; p8=9;

        w0=-1; w1=-1; w2=-1;
        w3=-1; w4=-1; w5=-1;
        w6=-1; w7=-1; w8=-1;

        bias = 0;

        valid_in = 1;

        @(negedge clk);
        valid_in = 0;


        wait(valid_out == 1);

        #1;

        $display("==============================");
        $display("TEST 2");
        $display("Conv Result = %d", conv_result);
        $display("ReLU Result = %d", relu_result);

        if (conv_result == -45 &&
            relu_result == 0)
            $display("TEST 2 PASSED");
        else
            $display("TEST 2 FAILED");

        $display("==============================");


        #20;

        $finish;

    end

endmodule
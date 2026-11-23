
`timescale 1ns/1ps

module synchronous_fifo_tb;

    reg clk;
    reg reset;
    reg wr_en;
    reg rd_en;
    reg [7:0] data_in;

    wire [7:0] data_out;
    wire full;
    wire empty;

    integer i;

    synchronous_fifo #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(16)
    ) uut (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin

        $dumpfile("fifo.vcd");
        $dumpvars(0, synchronous_fifo_tb);

        reset = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        repeat(2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Test 1: Check empty flag
        #1;
        if (empty !== 1)
            $fatal(1, "FAIL: FIFO should be EMPTY");

        $display("PASS: FIFO EMPTY condition");

        // Test 2: Write 16 data values
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            wr_en = 1;
            data_in = i + 1;
        end

        @(negedge clk);
        wr_en = 0;

        #1;
        if (full !== 1)
            $fatal(1, "FAIL: FIFO should be FULL");

        $display("PASS: FIFO FULL condition");

        // Test 3: Read all 16 data values
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            rd_en = 1;

            @(posedge clk);
            #1;

            if (data_out !== i + 1)
                $fatal(1, "FAIL: FIFO DATA mismatch at index %0d", i);
        end

        @(negedge clk);
        rd_en = 0;

        #1;
        if (empty !== 1)
            $fatal(1, "FAIL: FIFO should be EMPTY after reading");

        $display("PASS: FIFO READ operation");
        $display("PASS: ALL FIFO TESTS COMPLETED");

        $finish;
    end

endmodule

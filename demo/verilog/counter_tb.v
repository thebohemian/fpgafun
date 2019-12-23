// Verilog test bench for counter
//`timescale 1ns/100ps
`include "counter.v"

module counter_tb();

    reg tb_up_down, tb_clk, tb_rstn;
    wire[7:0] tb_out;

    always #1 tb_clk = !tb_clk;

    initial begin
        tb_up_down <= 1'b1;
        tb_rstn <= 1'b0;
        tb_clk <= 1'b0;

        #0.5 tb_rstn <= 1;

        #100 tb_rstn = 0;
        #1 tb_rstn = 1;
        #121 $finish;
    end

    counter sut(
        .up_down(tb_up_down),
        .clk(tb_clk),
        .rstn(tb_rstn),
        .out(tb_out),
    );

    initial begin
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, counter_tb);

        $monitor("At time %t, tb_out = %h (%0d) - tb_blazerg = %h (%0d)", $time, tb_out, tb_out, tb_blazerg, tb_blazerg);
    end

endmodule
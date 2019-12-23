// Verilog test bench for supercomputer
//`timescale 1ns/100ps
`timescale 1s/100ms
//`include "supercomputer.v"
`include "supercomputer_mk2.v"

module supercomputer_tb();

    reg tb_clk, tb_rstn, tb_handshake;
    reg[7:0] tb_cmd;
    reg[7:0] tb_arg;
    wire[3:0] tb_mem_adr;
    wire[7:0] tb_out;
    wire tb_jam;

    // clock, initial values, output
    always #0.5 tb_clk = !tb_clk;

    initial begin
        tb_rstn <= 1'b1;
        tb_clk <= 1'b0;
        tb_handshake <= 1'b0;

        $dumpfile("supercomputer_tb.vcd");
        $dumpvars(0, supercomputer_tb);

        $monitor("reg dump tb_out = %h", $time, tb_out);

        #0.1 tb_rstn <= 0;  // cause CPU reset
        #0.1 tb_rstn <= 1;  // starts normally
    end

    always @ (negedge tb_clk)
        tb_handshake <= 0;

    initial begin
        #0.3 begin
            tb_handshake <= 1'b1;

            // load 88 into A
            tb_cmd <= 8'h02;
            tb_arg <= 8'h88;
        end
        #1 begin
            tb_handshake <= 1'b1;

            // add 2 to A ( => 8A)
            tb_cmd <= 8'h04;
            tb_arg <= 8'h02;
        end
        #1 begin
            tb_handshake <= 1'b1;

            // subtract (8A) from A ( => 0)
            tb_cmd <= 8'h05;
            tb_arg <= 8'h8A;
        end
        #1 begin
            tb_handshake <= 1'b1;

            // flip all bits of A ( => 0xFF)
            tb_cmd <= 8'h01;
            tb_arg <= 8'h00;
        end
        #1 begin
            tb_handshake <= 1'b1;

            // load 07 into pointer
            tb_cmd <= 8'h03;
            tb_arg <= 8'h07;
        end
        #1 begin
            tb_handshake <= 1'b1;

            // store A into memory[pointer]
            tb_cmd <= 8'h06;
            tb_arg <= 8'h00;
        end
        #1 begin
            tb_handshake <= 1'b1;

            // jam CPU
            tb_cmd <= 8'hFF;
        end
        #1 begin
            tb_handshake <= 1'b1;

            // attempt to zero A (will be ignored; CPU jammed!)
            tb_cmd <= 8'h00;
            tb_arg <= 8'h00;
        end

        #1 tb_rstn <= 0;   // reset CPU

        #1 begin
            tb_rstn <= 1;   // stop resetting
            // load A with 0x44
            tb_handshake <= 1'b1;
            tb_cmd <= 8'h02;
            tb_arg <= 8'h44;
        end
        #1 begin
            tb_handshake <= 1'b1;
            tb_cmd <= 8'h07;    // NOP
        end

        #5 $finish;
    end

    supercomputer sut(
        tb_clk,
        tb_rstn,
        tb_handshake,
        tb_cmd,
        tb_arg,
        tb_mem_adr,
        tb_out,
        tb_jam
    );

endmodule
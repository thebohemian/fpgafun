
module supercomputer (
    input wire clk,
    input wire rstn,
    input wire handshake,
    input wire [7:0] cmd,
    input wire [7:0] arg,
    output reg [3:0] mem_addr,
    output reg [7:0] out,
    output reg jam
);

    reg [7:0] reg_A;
    reg [3:0] pointer;

always @ (posedge clk)
    if (!rstn) begin
        // resets CPU
        out <= 8'b01_01_01_01;
        mem_addr <= 0;
        reg_A <= 0;
        pointer <= 0;
        jam <= 0;
    end
    else if (jam) begin
        // blocks CPU
        out <= 8'b11_11_11_11;
        mem_addr <= 0;
    end else if (!handshake) begin
        /* NOP */
    end
    else begin
        case (cmd)
            // A := 0
            8'h00: reg_A <= 0;
            // A := !A
            8'h01: reg_A <= ~reg_A;
            // A := arg
            8'h02: reg_A <= arg;
            // pointer := arg & $0F
            8'h03: pointer <= arg[3:0];
            // A := A + arg
            8'h04: reg_A <= reg_A + arg;
            // A := A - arg
            8'h05: reg_A <= reg_A - arg;
            // store A
            8'h06: begin mem_addr <= pointer; out <= reg_A; end
            8'h07: begin /* NOP */ end
            default: jam <= 1;
        endcase
    end
endmodule
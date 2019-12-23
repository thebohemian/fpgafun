//
// PWM DAC
//
// MSBI is the highest bit number. NOT amount of bits!
//
module sigma_delta_dac #(parameter MSBI=17, parameter INV=1'b1)
(
   output reg      out, //Average Output feeding analog lowpass
   input [MSBI:0] in,  //DAC input (excess 2**MSBI)

   input           clk,
   input           reset
);
	
reg [MSBI+2:0] DeltaAdder; //Output of Delta Adder
reg [MSBI+2:0] SigmaAdder; //Output of Sigma Adder
reg [MSBI+2:0] SigmaLatch; //Latches output of Sigma Adder
reg [MSBI+2:0] DeltaB;     //B input of Delta Adder

always @(*) DeltaB = {SigmaLatch[MSBI+2], SigmaLatch[MSBI+2]} << (MSBI+1);
always @(*) DeltaAdder = in + DeltaB;
always @(*) SigmaAdder = DeltaAdder + SigmaLatch;

always @(posedge clk or posedge reset) begin
   if(reset) begin
      SigmaLatch <= 1'b1 << (MSBI+1);
      out <= INV;
   end else begin
      SigmaLatch <= SigmaAdder;
      out <= SigmaLatch[MSBI+2] ^ INV;
   end
end

endmodule

module counter (
    input up_down, clk, rstn,
    output reg RLED1 = 0, 
    output reg RLED2 = 0, 
    output reg RLED3 = 0, 
    output reg RLED4 = 0, 
    output reg RLED5 = 0, 
    output reg RLED6 = 0, 
    output reg RLED7 = 0, 
    output reg RLED8 = 0
);
	
	reg dir 

always @ (posedge clk)
    if (!rstn)
        out <= 0;
    else begin
        if (up_down)
            out <= out + 1;
        else
            out <= out - 1;
    end
endmodule
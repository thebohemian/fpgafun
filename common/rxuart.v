// Documented Verilog UART
// Copyright (C) 2010 Timothy Goddard (tim@goddard.net.nz)
// Distributed under the MIT licence.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
module rxuart
		#(
		// clock rate (12Mhz) / (baud rate (9600) * 4)
		parameter CLOCK_DIVIDE = 312)
		
		(
		input clk, // The master clock for this module
		input rx, // Incoming serial line
		output received, // Indicated that a byte has been received.
		output [7:0] rx_byte, // Byte received
		output is_receiving, // Low when receive line is idle.
		output recv_error // Indicates error in receiving packet.
		);

	// States for the receiving state machine.
	// These are just constants, not parameters to override.
	localparam RX_IDLE = 0;
	localparam RX_CHECK_START = 1;
	localparam RX_READ_BITS = 2;
	localparam RX_CHECK_STOP = 3;
	localparam RX_DELAY_RESTART = 4;
	localparam RX_ERROR = 5;
	localparam RX_RECEIVED = 6;
	
	localparam CLOCK_DIVIDE_BITS = $clog2(CLOCK_DIVIDE);

	reg [CLOCK_DIVIDE_BITS-1:0] rx_clk_divider = CLOCK_DIVIDE;

	reg [2:0] recv_state = RX_IDLE;
	reg [5:0] rx_countdown = 0;
	reg [3:0] rx_bits_remaining = 0;
	reg [7:0] rx_data = 0;

	assign received = recv_state == RX_RECEIVED;
	assign recv_error = recv_state == RX_ERROR;
	assign is_receiving = recv_state != RX_IDLE;
	assign rx_byte = rx_data;

	always @(posedge clk) begin
		begin

			// The clk_divider counter counts down from
			// the CLOCK_DIVIDE constant. Whenever it
			// reaches 0, 1/16 of the bit period has elapsed.
			// Countdown timers for the receiving and transmitting
			// state machines are decremented.
			rx_clk_divider = rx_clk_divider - 1;
			if (!rx_clk_divider) begin
				rx_clk_divider = CLOCK_DIVIDE;
				rx_countdown = rx_countdown - 1;
			end

			// Receive state machine
			case (recv_state)
				RX_IDLE: begin
					// A low pulse on the receive line indicates the
					// start of data.
					if (!rx) begin
						// Wait half the period - should resume in the
						// middle of this first pulse.
						rx_clk_divider = CLOCK_DIVIDE;
						rx_countdown = 2;
						recv_state = RX_CHECK_START;
					end
				end
				RX_CHECK_START: begin
					if (!rx_countdown) begin
						// Check the pulse is still there
						if (!rx) begin
							// Pulse still there - good
							// Wait the bit period to resume half-way
							// through the first bit.
							rx_countdown = 4;
							rx_bits_remaining = 8;
							recv_state = RX_READ_BITS;
						end else begin
							// Pulse lasted less than half the period -
							// not a valid transmission.
							recv_state = RX_ERROR;
						end
					end
				end
				RX_READ_BITS: begin
					if (!rx_countdown) begin
						// Should be half-way through a bit pulse here.
						// Read this bit in, wait for the next if we
						// have more to get.
						rx_data = {rx, rx_data[7:1]};
						rx_countdown = 4;
						rx_bits_remaining = rx_bits_remaining - 1;
						recv_state = rx_bits_remaining ? RX_READ_BITS : RX_CHECK_STOP;
					end
				end
				RX_CHECK_STOP: begin
					if (!rx_countdown) begin
						// Should resume half-way through the stop bit
						// This should be high - if not, reject the
						// transmission and signal an error.
						recv_state = rx ? RX_RECEIVED : RX_ERROR;
					end
				end
				RX_DELAY_RESTART: begin
					// Waits a set number of cycles before accepting
					// another transmission.
					recv_state = rx_countdown ? RX_DELAY_RESTART : RX_IDLE;
				end
				RX_ERROR: begin
					// There was an error receiving.
					// Raises the recv_error flag for one clock
					// cycle while in this state and then waits
					// 2 bit periods before accepting another
					// transmission.
					rx_countdown = 8;
					recv_state = RX_DELAY_RESTART;
				end
				RX_RECEIVED: begin
					// Successfully received a byte.
					// Raises the received flag for one clock
					// cycle while in this state.
					recv_state = RX_IDLE;
					rx_countdown <= 1;
				end
			endcase
		end
	end

endmodule

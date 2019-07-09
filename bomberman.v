`timescale 1ns / 1ns





// Part 2 skeleton

module lab6_part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			//.colour(colour),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
        
    // Instansiate datapath
	datapath d0(.input_colour(SW[9:7]),
				.coords(SW[6:0]),
				.xOffset(xoffset),
				.yOffset(yoffset),
				.resetn(KEY[0]),
				.saveX(KEY[3]),
				.finalX(x),
				.finalY(y),
				.output_colour(colour));
	
	wire [1:0] xoffset, yoffset;
	// Instansiate FSM control
    control c0(.clk(CLOCK_50),
				.go(!KEY[1]),
    		   .resetn(KEY[0]),
    		   .xOffset(xoffset),
    		   .yOffset(yoffset),
    		   .plot(writeEn));
    
endmodule

module datapath(
	input [2:0] input_colour,
	input [6:0] coords,
	input [1:0] xOffset,
	input [1:0] yOffset,
	input resetn,
	input saveX,
	output[7:0] finalX,
	output[6:0] finalY,
	output[2:0] output_colour
	);
	
	// setup x coordinate
	reg[7:0] x_coordinate;

	always @ (posedge saveX) begin
		x_coordinate <= {1'b0, coords};
	end
	
	assign finalY = {coords + yOffset};
	assign finalX = {x_coordinate + xOffset};
	
	// set color
	assign output_colour = input_colour[2:0];

endmodule

module control(
	input clk,
	input resetn,
	input go,
	
	output reg [1:0] xOffset,
	output reg [1:0] yOffset,
	output plot);
	
	reg [5:0] current_state, next_state;

	localparam 	P1      = 5'd0,
				P2      = 5'd1,
				P3      = 5'd2,
				P4      = 5'd3,
				P5      = 5'd4,
				P6      = 5'd5,
				P7      = 5'd6,
				P8      = 5'd7,
				P9      = 5'd8,
				P10     = 5'd9,
				P11     = 5'd10,
				P12     = 5'd11,
				P13     = 5'd12,
				P14     = 5'd13,
				P15     = 5'd14,
				P16     = 5'd15,
				RESTING = 5'd16;
				
	always@(posedge clk)
	begin: state_table
		case (current_state)
			P1: next_state = P2;
			P2: next_state = P3;
			P3: next_state = P4;
			P4: next_state = P5;
			P5: next_state = P6;
			P6: next_state = P7;
			P7: next_state = P8;
			P8: next_state = P9;
			P9: next_state = P10;
			P10: next_state = P11;
			P11: next_state = P12;
			P12: next_state = P13;
			P13: next_state = P14;
			P14: next_state = P15;
			P15: next_state = P16;
			P16: next_state = RESTING;
			RESTING: next_state = go ? P1 : RESTING;
			default: next_state = RESTING;	
		endcase
	end
	
	// plot
	assign plot = (current_state != RESTING);
	
	// assign offset
	always@(*)
	begin: make_output
		case(current_state)
			P1: begin
				xOffset <= 2'b00;
				yOffset <= 2'b00;
				end
			P2: begin
				xOffset <= 2'b01;
				yOffset <= 2'b00;
				end
			P3: begin
				xOffset <= 2'b10;
				yOffset <= 2'b00;
				end
			P4: begin
				xOffset <= 2'b11;
				yOffset <= 2'b00;
				end
			P5: begin
				xOffset <= 2'b00;
				yOffset <= 2'b01;
				end
			P6: begin
				xOffset <= 2'b01;
				yOffset <= 2'b01;
				end
			P7: begin
				xOffset <= 2'b10;
				yOffset <= 2'b01;
				end
			P8: begin
				xOffset <= 2'b11;
				yOffset <= 2'b01;
				end
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
			P9: begin
				xOffset <= 2'b00;
				yOffset <= 2'b10;
				end
			P10: begin
				xOffset <= 2'b01;
				yOffset <= 2'b10;
				end
			P11: begin
				xOffset <= 2'b10;
				yOffset <= 2'b10;
				end
			P12: begin
				xOffset <= 2'b11;
				yOffset <= 2'b10;
				end
			P13: begin
				xOffset <= 2'b00;
				yOffset <= 2'b11;
				end
			P14: begin
				xOffset <= 2'b01;
				yOffset <= 2'b11;
				end
			P15: begin
				xOffset <= 2'b10;
				yOffset <= 2'b11;
				end
			P16: begin
				xOffset <= 2'b11;
				yOffset <= 2'b11;
				end
			default: begin
				xOffset <= 2'b00;
				yOffset <= 2'b00;
				end
			endcase
	
	end

	always@(posedge clk)
	begin: state_FFs
		if(!resetn) // goto resting if reset
			current_state <= RESTING;
		else
			current_state <= next_state;
	end
				
endmodule

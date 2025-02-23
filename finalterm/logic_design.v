module logic_design(input [4:0] SW, input CLOCK_50, output reg [0:6] HEX0,HEX1,HEX3);
//newClk is for new, slow clock.
//isInput is to check if the input is wrong or not.
wire newClk, isInput;
//input_sw is a 3 bit conversion of input SW.
wire [2:0] input_sw;
//a, b, c is current state, next_, next_b, next_c is next state.
reg a, b, c, next_a, next_b, next_c;

parameter state_0 = 3'b000; parameter state_4 = 3'b001; parameter state_8 = 3'b010;
parameter state_12 = 3'b011; parameter state_16 = 3'b100; parameter state_20 = 3'b101;
parameter Seg9 = 7'b000_1100; parameter Seg8 = 7'b000_0000; parameter Seg7 = 7'b000_1111;
parameter Seg6 = 7'b010_0000; parameter Seg5 = 7'b010_0100; parameter Seg4 = 7'b100_1100;
parameter Seg3 = 7'b000_0110; parameter Seg2 = 7'b001_0010; parameter Seg1 = 7'b100_1111; parameter Seg0 = 7'b000_0001;

//Make slow clock.
clock(CLOCK_50, newClk);
//Convert SW to 3 bit input_sw.
assign input_sw[0] = SW[3]|SW[1];
assign input_sw[1] = SW[3]|SW[2];
assign input_sw[2] = SW[4];
//Check if only one of SW is on at the same time.
assign isInput = (~SW[4]&~SW[3]&~SW[2]&~SW[1]&SW[0])|(~SW[4]&~SW[3]&~SW[2]&SW[1]&~SW[0])|(~SW[4]&~SW[3]&SW[2]&~SW[1]&~SW[0])|(~SW[4]&SW[3]&~SW[2]&~SW[1]&~SW[0])|(SW[4]&~SW[3]&~SW[2]&~SW[1]&~SW[0]);

//Set initial next_a, next_b, next_c to 0.
initial
begin
	next_a = 1'b0;
	next_b = 1'b0;
	next_c = 1'b0;
end

//When positive edge of newClk, set a, b, c to new_a, new_b, new_c.
always @(posedge newClk)
begin
	a <= next_a; b <= next_b; c <= next_c;
end

//When positive edge of isInput
always @(posedge isInput)
begin
	//If input_sw[2] is on, then reset to 0.
	if(input_sw[2])
	begin
		next_a <= 1'b0; next_b <= 1'b0; next_c <= 1'b0;
	end
	//If input_sw[2] is off, then set the value using k-map.
	else
	begin
		next_a <= (a&~input_sw[1])|(a&~input_sw[0])|(b&~input_sw[1]&input_sw[0])|(b&c&~input_sw[1])|(~b&c&input_sw[1]&~input_sw[0])|(b&~c&input_sw[1]&~input_sw[0]);
		next_b <= (a&input_sw[1]&input_sw[0])|(~a&~b&~input_sw[1]&input_sw[0])|(~a&~b&c&~input_sw[1])|(b&~c&~input_sw[1]&~input_sw[0])|(b&c&input_sw[1]&~input_sw[0])|(~a&~b&~c&input_sw[1]&~input_sw[0]);
		next_c <= (c&input_sw[0])|(a&c)|(~a&~c&~input_sw[0])|(~c&~input_sw[1]&~input_sw[0])|(b&input_sw[1]&~input_sw[0]);
	end
end

always @(*)
begin
	//Print HEX0, HEX1, and HEX3 by {a, b, c}.
	case({a, b, c})
		state_0: begin HEX3 = Seg0; HEX1 = Seg0; HEX0 = Seg0; end
		state_4: begin HEX3 = Seg0; HEX1 = Seg0; HEX0 = Seg4; end 
		state_8: begin HEX3 = Seg1; HEX1 = Seg0; HEX0 = Seg8; end
		state_12: begin HEX3 = Seg1; HEX1 = Seg1; HEX0 = Seg2; end
		state_16: begin HEX3 = Seg2; HEX1 = Seg1; HEX0 = Seg6; end
		state_20: begin HEX3 = Seg2; HEX1 = Seg2; HEX0 = Seg0; end
	endcase
end
endmodule

//Make slow clock using clk.
module clock(input clk, output newclk);
	reg [24:0]cnt;
	
	//When positive edge of clk, add cnt 1.
	always@(posedge clk)
	begin
		cnt <= cnt + 1'b1;
	end
	//For every 2^22 counts, invert the output.
	assign newclk = cnt[22];
endmodule

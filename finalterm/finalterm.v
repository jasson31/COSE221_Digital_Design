module finalterm(input [4:0] SW, input CLOCK_50, output reg [0:6] HEX0,HEX1,HEX3, output reg [7:0] LEDG);
wire newClk, isInput;
wire [2:0] input_sw;
reg a, b, c, next_a, next_b, next_c;

parameter state_0 = 3'b000; parameter state_4 = 3'b001; parameter state_8 = 3'b010;
parameter state_12 = 3'b011; parameter state_16 = 3'b100; parameter state_20 = 3'b101;

parameter input_4 = 3'b000; parameter input_8 = 3'b001; parameter input_12 = 3'b010;
parameter input_n8 = 3'b011; parameter input_null = 3'b100;

parameter Seg9 = 7'b000_1100; parameter Seg8 = 7'b000_0000; parameter Seg7 = 7'b000_1111;
parameter Seg6 = 7'b010_0000; parameter Seg5 = 7'b010_0100; parameter Seg4 = 7'b100_1100;
parameter Seg3 = 7'b000_0110; parameter Seg2 = 7'b001_0010; parameter Seg1 = 7'b100_1111; parameter Seg0 = 7'b000_0001;

clock(CLOCK_50, newClk);

assign input_sw[0] = SW[3]|SW[1];
assign input_sw[1] = SW[3]|SW[2];
assign input_sw[2] = SW[4];
assign isInput = (~SW[4]&~SW[3]&~SW[2]&~SW[1]&SW[0])|(~SW[4]&~SW[3]&~SW[2]&SW[1]&~SW[0])|(~SW[4]&~SW[3]&SW[2]&~SW[1]&~SW[0])|(~SW[4]&SW[3]&~SW[2]&~SW[1]&~SW[0])|(SW[4]&~SW[3]&~SW[2]&~SW[1]&~SW[0]);

initial
begin
	next_a = 1'b0;
	next_b = 1'b0;
	next_c = 1'b0;
end

always @(posedge newClk)
begin
	a <= next_a; b <= next_b; c <= next_c;
end

always @(posedge isInput)
begin
	if(input_sw[2])
	begin
		next_a <= 1'b0; next_b <= 1'b0; next_c <= 1'b0;
	end
	else
	begin
		if(isInput)
		begin
			next_a <= ((a&~input_sw[1])|(a&~input_sw[0])|(b&~input_sw[1]&input_sw[0])|(b&c&~input_sw[1])|(~b&c&input_sw[1]&~input_sw[0])|(b&~c&input_sw[1]&~input_sw[0]));
			next_b <= ((a&input_sw[1]&input_sw[0])|(~a&~b&~input_sw[1]&input_sw[0])|(~a&~b&c&~input_sw[1])|(b&~c&~input_sw[1]&~input_sw[0])|(b&c&input_sw[1]&~input_sw[0])|(~a&~b&~c&input_sw[1]&~input_sw[0]));
			next_c <= ((c&input_sw[0])|(a&c)|(~a&~c&~input_sw[0])|(~c&~input_sw[1]&~input_sw[0])|(b&input_sw[1]&~input_sw[0]));
		end
	end
end

always @(*)
begin
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


module clock(input clk, output newclk);
	reg [24:0]cnt;
	
	always@(posedge clk)
	begin
		cnt <= cnt + 1'b1;
	end
	assign newclk = cnt[24];
endmodule

/*always @(*)
begin
	if(a)
		LEDG[2] = 1'b1;
	else
		LEDG[2] = 1'b0;
	if(b)
		LEDG[1] = 1'b1;
	else
		LEDG[1] = 1'b0;
	if(c)
		LEDG[0] = 1'b1;
	else
		LEDG[0] = 1'b0;
		
	if(next_a)
		LEDG[7] = 1'b1;
	else
		LEDG[7] = 1'b0;
	if(next_b)
		LEDG[6] = 1'b1;
	else
		LEDG[6] = 1'b0;
	if(next_c)
		LEDG[5] = 1'b1;
	else
		LEDG[5] = 1'b0;
end*/
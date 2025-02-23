module midterm_sim( 
	input [16:0] SW,
	output reg [0:6] HEX0, HEX1, HEX4, HEX5, HEX6, HEX7,
	output reg [8:0] LEDG
);
//input 1 is for first input, and 2 is for second input.
//operator is for (+) or (-).
reg [3:0] input1_1, input1_2, input2_1, input2_2, operator;
//flow detector detects whether overflow / underflow occurred or not.
reg car_0, flow_detector;
wire [3:0] sum1, sum2, complement1, complement2;
wire car_1, car_2;
parameter Seg9 = 7'b000_1100;parameter Seg8 = 7'b000_0000;parameter Seg7 = 7'b000_1111;
parameter Seg6 = 7'b010_0000;parameter Seg5 = 7'b010_0100;parameter Seg4 = 7'b100_1100;
parameter Seg3 = 7'b000_0110;parameter Seg2 = 7'b001_0010;parameter Seg1 = 7'b100_1111;
parameter Seg0 = 7'b000_0001;

//Generate 9's complement of second input.
comple9_gen comple9_gen1 (input2_1, operator, complement1);
comple9_gen comple9_gen2 (input2_2, operator, complement2);
//Add first input and second input after making complement.
bcd_adder bcd_adder1 (sum1, car_1, complement1, input1_1, car_0);
bcd_adder bcd_adder2 (sum2, car_2, complement2, input1_2, car_1);

//Get BCD input from SW[15] to SW[8] as input 1, and from SW[7] to SW[0] as input2.
//Check if operator is (+) or (-).
always @(*)
begin
	input2_1 = SW[3:0];
	input2_2 = SW[7:4];
	input1_1 = SW[11:8];
	input1_2 = SW[15:12];
	operator = SW[16];
	car_0 = operator;
	//Overflow : carry occurred when operator is (+)
	//Underflow : carry not occurred when operator is (-)
	flow_detector = car_2 ^ operator;
end

//Determine segments' output.
always @(*)
begin
	case(SW[15:12])
		9:HEX7=Seg9;     8:HEX7=Seg8;	7:HEX7=Seg7;	6:HEX7=Seg6;
		5:HEX7=Seg5;	4:HEX7=Seg4;	3:HEX7=Seg3;	2:HEX7=Seg2;
		1:HEX7=Seg1;	0:HEX7=Seg0;	default: HEX7 = 7'b1111111;
	endcase
	case(SW[11:8])
		9:HEX6=Seg9;     8:HEX6=Seg8;	7:HEX6=Seg7;	6:HEX6=Seg6;
		5:HEX6=Seg5;	4:HEX6=Seg4;	3:HEX6=Seg3;	2:HEX6=Seg2;
		1:HEX6=Seg1;	0:HEX6=Seg0;	default: HEX6 = 7'b1111111;
	endcase
	case(SW[7:4])
		9:HEX5=Seg9;     8:HEX5=Seg8;	7:HEX5=Seg7;	6:HEX5=Seg6;
		5:HEX5=Seg5;	4:HEX5=Seg4;	3:HEX5=Seg3;	2:HEX5=Seg2;
		1:HEX5=Seg1;	0:HEX5=Seg0;	default: HEX5 = 7'b1111111;
	endcase
	case(SW[3:0])
		9:HEX4=Seg9;	8:HEX4=Seg8;	7:HEX4=Seg7;	6:HEX4=Seg6;
		5:HEX4=Seg5;	4:HEX4=Seg4;	3:HEX4=Seg3;	2:HEX4=Seg2;
		1:HEX4=Seg1;	0:HEX4=Seg0;	default: HEX4 = 7'b1111111;
	endcase
	//Check if input is bcd number and flow has occurred.
	if(~flow_detector & (SW[15:12] < 10 & SW[11:8] < 10 & SW[7:4] < 10 & SW[3:0] < 10))
		//If input is proper and flow has not occurred, then print the result.
		begin
			case(sum2)
				9:HEX1=Seg9;	8:HEX1=Seg8;	7:HEX1=Seg7;	6:HEX1=Seg6;
				5:HEX1=Seg5;	4:HEX1=Seg4;	3:HEX1=Seg3;	2:HEX1=Seg2;
				1:HEX1=Seg1;	0:HEX1=Seg0;	default: HEX1 = 7'b1111111;
			endcase
			case(sum1)
				9:HEX0=Seg9;	8:HEX0=Seg8;	7:HEX0=Seg7;	6:HEX0=Seg6;
				5:HEX0=Seg5;	4:HEX0=Seg4;	3:HEX0=Seg3;	2:HEX0=Seg2;
				1:HEX0=Seg1;	0:HEX0=Seg0;	default: HEX0 = 7'b1111111;
			endcase
			LEDG[8] = 1'b0;
		end
	else
		//If input is improper or flow has occurred, then turn off result segment and turn on led.
		begin
			HEX1 = 7'b1111111;
			HEX0 = 7'b1111111;
			LEDG[8] = 1'b1;
		end
end
endmodule

//Full adder of bcd number.
//Add two bcd input a and b with carry cin and assign it to the sum.
//Carry is assigned to the car.
module bcd_adder(sum, car, a, b, cin);
output [3:0] sum;
output car;
input [3:0] a, b;
input cin;
wire [3:0] sum_temp, bcdcar;
wire car_temp, temp;

//At first, add two number as ordinary 4 bit binary number.
full_adder full_adder1(sum_temp, car_temp, a, b, cin);
//If the result is not bcd(result is larger than 9), then carry has occured.
assign car = car_temp | (sum_temp[3] & (sum_temp[2] | sum_temp[1]));
assign bcdcar[0] = 1'b0;
assign bcdcar[1] = car;
assign bcdcar[2] = car;
assign bcdcar[3] = 1'b0;
//If carry has occurred, then add 6 again to the result.
full_adder full_adder2(sum, temp, bcdcar, sum_temp, 1'b0);

endmodule

//Full adder of 4-bit binary number.
//Add two binary input a and b with carry cin and assign it to the sum.
//Carry is assigned to the car.
module full_adder(sum, car, a, b, cin);
output [3:0] sum;
output car;
input [3:0] a, b;
input cin;
wire [2:0] c;

assign sum[0]=a[0] ^ b[0] ^ cin;
assign c[0]=((a[0] ^ b[0]) & cin) | (a[0] & b[0]);

assign sum[1]=a[1] ^ b[1] ^ c[0];
assign c[1]=((a[1] ^ b[1]) & c[0]) | (a[1] & b[1]);

assign sum[2]=a[2] ^ b[2] ^ c[1];
assign c[2]=((a[2] ^ b[2]) & c[1]) | (a[2] & b[2]);

assign sum[3]=a[3] ^ b[3] ^ c[2];
assign car=((a[3] ^ b[3]) & c[2]) | (a[3] & b[3]);

endmodule

//Generates 9's complement of num_origin and assign the result to num_comple.
//If operator is (+), then the result would be just as same as the input(not 9's complement).
//If operator is (-), then the result would be 9's complement.
module comple9_gen(num_origin, operator, num_comple);
input [3:0] num_origin;
input operator;
output [3:0] num_comple;

//This logic is made by K-map.
assign num_comple[3] = (operator & ~num_origin[3] & ~num_origin[2] & ~num_origin[1]) | (~operator & num_origin[3]);
assign num_comple[2] = (operator & (num_origin[2] ^ num_origin[1])) | (~operator & num_origin[2]);
assign num_comple[1] = num_origin[1];
assign num_comple[0] = operator ^ num_origin[0];

endmodule

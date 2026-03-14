// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* ECO_CHECKSUM = "300f98d4" *) 
module top_basys3(clk, sw, led, btnL, btnR);
  input clk;
  input [15:0]sw;
  output [15:0]led;
  input btnL;
  input btnR;
endmodule

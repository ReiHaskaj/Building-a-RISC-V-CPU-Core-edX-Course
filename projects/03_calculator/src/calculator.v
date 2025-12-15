\m5_TLV_version 1d: tl-x.org
\m5
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.

\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module

   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/calc_viz.tlv'])
					
\TLV
   
   $val1upper[25:0] = 25'd0;
   $val1[31:0] = {$val1upper, $val1_rand[5:0]}; // Setting the first 26 bits of val1 to 0.
   
   $val2upper[27:0] = 28'd0;
   $val2[31:0] = {$val2upper, $val2_rand[3:0]}; // Setting the first 28 bits of val2 to 0.
   
   
   $sum[31:0] = $val1[31:0] + $val2[31:0];
   $diff[31:0] = $val1[31:0] - $val2[31:0];
   $prod[31:0] = $val1[31:0] * $val2[31:0];
   $quot[31:0] = $val1[31:0] / $val2[31:0]; // The mathematical functions.

				   
   // The 4x1 Multiplexer.
   $out[31:0] = $op[1:0] == 0 ? $sum[31:0] :
                $op[1:0] == 1 ? $diff[31:0] :
                $op[1:0] == 2 ? $prod[31:0] :
				                $quot[31:0];  // $op[1:0] == 3; Default case.
                
   
   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   
   m4+calc_viz()
\SV
   endmodule

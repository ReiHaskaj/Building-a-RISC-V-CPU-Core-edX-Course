\m5_TLV_version 1d: tl-x.org
\m5
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.

\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   

\TLV
   $reset = *reset;
   
   $out[7:0] = $in1[6:0] + $in2[6:0]; //Add
   $out[7:0] = $in1[6:0] - $in2[6:0]; //Subtract
   $out[7:0] = $in1[6:0] * $in2[6:0]; //Product
   $out[7:0] = $in1[6:0] / $in2[6:0]; //Divide

   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule

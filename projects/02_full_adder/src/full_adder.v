\m5_TLV_version 1d: tl-x.org
\m5

   //use(m5-1.0)   /// uncomment to use M5 macro library.

\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module

\TLV
   $reset = *reset;
   
   $out1 = $val1 ^ $val2;
   $out2 = $val1 && $val2;  // Carry from the first half_adder.
   
   $sum = $out1 ^ $carryin;  // Sum result.
   $out3 = $out1 && $carryin;  // Carry from the second half_adder.
   
   $carryout = $out3 || $out2;  // Carry out result.
   
   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule

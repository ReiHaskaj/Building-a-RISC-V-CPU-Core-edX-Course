\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])

   m4_test_prog()

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
\TLV
   
   $reset = *reset;


   // Program Counter
   //$pc[1:0] = 2'b00; //lower 2 bits of the pc variable should be 0.
   $pc[31:0] = >>1$next_pc[31:0];
   //$next_pc[31:0] = $reset ? 0 : {$pc[31:2],2'b00} + 32'd4; //Program counter. Right now a simple counter. Used to fetch instruction from Instruction Memory.
   
   $next_pc[31:0] = $reset ? 32'b0 :
                    $taken_br ? $br_tgt_pc :
                    $is_jal ? $br_tgt_pc :
                    $is_jalr ? $jalr_tgt_pc :
                    $pc + 32'd4;

                   
   // Instruction memory. The program counter says instruction x needs to be fetched.
   `READONLY_MEM($pc[31:0],  $$instr[31:0]);
   
   
   //Decode Logic. Now we need to know what type of instruction we just fetched. We check the opcodes.
   $is_u_instr = $instr[6:2] ==? 5'b0x101; // Checks if instruction is of type U or not.
   $is_i_instr = $instr[6:2] == 5'b00000 || $instr[6:2] == 5'b00001 || $instr[6:2] == 5'b00100 || $instr[6:2] == 5'b00110 || $instr[6:2] == 5'b11001; // Checks if instruction is of type I.
   $is_r_instr = $instr[6:2] == 5'b01011 || $instr[6:2] == 5'b01100 || $instr[6:2] == 5'b01110 || $instr[6:2] == 5'b10100; // Checks if instruction is of type R.
   $is_s_instr = $instr[6:2] ==? 5'b0100x; // Checks if instruction is of type S.
   $is_b_instr = $instr[6:2] == 5'b11000; // Checks if instruction is of type B.
   $is_j_instr = $instr[6:2] == 5'b11011; // Checks if instruction is of type J.
   
   
   //Extracting instruction fields for non-immediate instructions:
   $rs2[4:0] = $instr[24:20];
   $rs1[4:0] = $instr[19:15];
   $funct3[2:0] = $instr[14:12];
   $rd[4:0] = $instr[11:7];
   $opcode[6:0] = $instr[6:0];
                   
   
   //Determine when the fields are valid:
   $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
   $rs1_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
   $rd_valid = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr; //was like this
   
   //$rd_valid = $rd[4:0] == 5'b00000 ? 1'b0 : //new. Prevents from doing anything on register x0. Causes a problem in my simulation for JAL!
               //$is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr; //new: || $is_load.
   
   $imm_valid = $is_i_instr || $is_s_instr || $is_b_instr || $is_u_instr || $is_j_instr;
   
   //Suppresses the warnings on the Log for the following signals:
   `BOGUS_USE($rd $rd_valid $rs1 $rs1_valid $rs2 $rs2_valid $imm_valid $opcode $funct3);
   
   // Dealing with immediate: 
   $imm[31:0] = $is_i_instr ? {  {21{$instr[31]}},  $instr[30:20]  } :
                $is_s_instr ? {  {21{$instr[31]}},  $instr[30:25],  $instr[11:7]  } :
                $is_b_instr ? {  {20{$instr[31]}},  $instr[7],  $instr[30:25],  $instr[11:8],  1'b0  } :
                $is_u_instr ? {  $instr[31],  $instr[30:20],  $instr[19:12],  12'b0  } :
                $is_j_instr ? {  {12{$instr[31]}},  $instr[19:12],  $instr[20],  $instr[30:25],  $instr[24:21],  1'b0  } :
                              32'b0;  // Default
   
   
   //Decode Logic: Instructions.
   
   $dec_bits[10:0] = {$instr[30],$funct3,$opcode};
   
   $is_beq = $dec_bits ==? 11'bx_000_1100011; //check if the instruction is BEQ.
   $is_bne = $dec_bits ==? 11'bx_001_1100011; //check if the instruction is BNE.
   $is_blt = $dec_bits ==? 11'bx_100_1100011; //check if the instruction is BLT.
   $is_bge = $dec_bits ==? 11'bx_101_1100011; //check if the instruction is BGE.
   $is_bltu = $dec_bits ==? 11'bx_110_1100011; //check if the instruction is BLTU.
   $is_bgeu = $dec_bits ==? 11'bx_111_1100011; //check if the instruction is BGEU.
   
   $is_addi = $dec_bits ==? 11'bx_000_0010011; //check if the instruction is ADDI.
   
   $is_add = $dec_bits == 11'b0_000_0110011; //check if the instruction is ADD.
   
   //The remaining Instructions:
   $is_lui = $dec_bits ==? 11'bx_xxx_0110111; //check if the instruction is LUI.
   $is_auipc = $dec_bits ==? 11'bx_xxx_0010111; //check if the instruction is AUIPC.
   $is_jal = $dec_bits ==? 11'bx_xxx_1101111; //check if the instruction is JAL.
   $is_jalr = $dec_bits ==? 11'bx_000_1100111; //check if the instruction is JALR.
   
   $is_slti = $dec_bits ==? 11'bx_010_0010011; //check if the instruction is SLTI.
   
   $is_sltiu = $dec_bits ==? 11'bx_011_0010011; //check if the instruction is SLTIU.
   $is_xori = $dec_bits ==? 11'bx_100_0010011; //check if the instruction is XORI.
   $is_ori = $dec_bits ==? 11'bx_110_0010011; //check if the instruction is ORI.
   $is_andi = $dec_bits ==? 11'bx_111_0010011; //check if the instruction is ANDI.
   $is_slli = $dec_bits == 11'b0_001_0010011; //check if the instruction is SLLI.
   $is_srli = $dec_bits == 11'b0_101_0010011; //check if the instruction is SRLI.
   $is_srai = $dec_bits == 11'b1_101_0010011; //check if the instruction is SRAI.
   $is_sub = $dec_bits == 11'b1_000_0110011; //check if the instruction is SUB.
   $is_sll = $dec_bits == 11'b0_001_0110011; //check if the instruction is SLL.
   $is_slt = $dec_bits == 11'b0_010_0110011; //check if the instruction is SLT.
   $is_sltu = $dec_bits == 11'b0_011_0110011; //check if the instruction is SLTU.
   $is_xor = $dec_bits == 11'b0_100_0110011; //check if the instruction is XOR.
   $is_srl = $dec_bits == 11'b0_101_0110011; //check if the instruction is SRL.
   $is_sra = $dec_bits == 11'b1_101_0110011; //check if the instruction is SRA.
   $is_or = $dec_bits == 11'b0_110_0110011; //check if the instruction is OR.
   $is_and = $dec_bits == 11'b0_111_0110011; //check if the instruction is AND.
   
   $is_load = $dec_bits ==? 11'bx_xxx_0000011; //check if the instruction is LOAD or STORE of any kind.
   
   //check LOAD 52.
   
   
   `BOGUS_USE($imm $is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu $is_addi $is_add);
   
   
   //Register File
   
   //m4+rf(32, 32, $reset, $wr_en, $wr_index[4:0], $wr_data[31:0], $rs1_valid, $rs1[4:0], $src1_value, $rs2_valid, $rs2[4:0], $src2_value)
   //I am going to change $rd_en1 to $rs1_valid and $rd_index1[4:0] to $rs1[4:0].
   //The same goes for $rd_en2 to $rs2_valid and $rd_index2[4:0] to $rs2[4:0].
   //I am going to change $wr_en to $rd_valid and also $wr_index[4:0] to $rd[4:0]. Not needed now actually.
   
   
   //ALU
   
   //Intermediate reults useful for $result in some operations:
   $sltu_rslt[31:0] = {31'b0, $src1_value < $src2_value};
   $sltiu_rslt[31:0] = {31'b0, $src1_value < $imm};
   
   $sext_src1[63:0] = { {32{$src1_value[31]}}, $src1_value };
   
   $sra_rslt[63:0] = $sext_src1 >> $src2_value[4:0];
   $srai_rslt[63:0] = $sext_src1 >> $imm[4:0];
   
   $result[31:0] =
    $is_addi ? $src1_value + $imm :
    $is_add ? $src1_value + $src2_value :
    $is_andi ? $src1_value & $imm :
    $is_ori ? $src1_value | $imm :
    $is_xori ? $src1_value ^ $imm :
    $is_slli ? $src1_value << $imm[5:0] :
    $is_srli ? $src1_value >> $imm[5:0] : //problem
    $is_and ? $src1_value & $src2_value :
    $is_or ? $src1_value | $src2_value :
    $is_xor ? $src1_value ^ $src2_value :
    $is_sub ? $src1_value - $src2_value :
    $is_sll ? $src1_value << $src2_value[4:0] :
    $is_srl ? $src1_value >> $src2_value[4:0] :
    $is_sltu ? $sltu_rslt :
    $is_sltiu ? $sltiu_rslt :
    $is_and ? $src1_value & $src2_value :
    $is_lui ? {$imm[31:12], 12'b0} :
    $is_auipc ? $pc + $imm :
    $is_jal ? $pc + 32'd4 :
    $is_jalr ? $pc + 32'd4 :
    $is_load ? $src1_value + $imm : //new
    $is_s_instr ? $src1_value + $imm : //new
    $is_sra ? $sra_rslt[31:0] :
    $is_srai ? $srai_rslt[31:0] :
    $is_slt ? (($src1_value[31] == $src2_value[31]) ? $sltu_rslt : {31'b0, $src1_value[31]}) :
    $is_slti ? (($src1_value[31] == $imm[31]) ? $sltu_rslt : {31'b0, $src1_value[31]}) :
               32'b0; //default
   
   //Now we have the result that we can plug in into the $wr_data[31:0] of the register file.
   
   //Complete the result with all possible operations.
   
   
   //Branch Logic
   
   //Taken Branch:(($src_value1 >= $src_value2) ^ ($src_value1[31] != $src_value2[31]))
   $taken_br = $is_beq ? ($src1_value == $src2_value) :
               $is_bne ? ($src1_value != $src2_value) :
               $is_blt ? (($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
               $is_bge ? (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
               $is_bltu ? ($src1_value < $src2_value) :
               $is_bgeu ? ($src1_value >= $src2_value) :
                          1'b0;
   
   $br_tgt_pc[31:0] = $pc + $imm;
   
   //For the JUMP Instructions:
   $jalr_tgt_pc[31:0] = $src1_value + $imm;
   
   
   //Load Data: Output of DMem
   
   $new_result[31:0] = $is_load ? $ld_data[31:0] : $result;
   
   
   $passed_cond = (/xreg[30]$value == 32'b1) && (!$reset && $next_pc[31:0] == $pc[31:0]);
   
   
   
   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = >>2$passed_cond; //now we plug in the Testbench.
   //m4+tb()
   *failed = *cyc_cnt > M4_MAX_CYC;
   
   m4+rf(32, 32, $reset, ($rd_valid && $rd[4:0] != 5'b0), $rd[4:0], $new_result[31:0], $rs1_valid, $rs1[4:0], $src1_value, $rs2_valid, $rs2[4:0], $src2_value)
   m4+dmem(32, 32, $reset, $result[6:2], $is_s_instr, $src2_value[31:0], $is_load, $ld_data)
   //m4+rf(32, 32, $reset, $wr_en, $wr_index[4:0], $wr_data[31:0], $rd_en1, $rd_index1[4:0], $rd_data1, $rd_en2, $rd_index2[4:0], $rd_data2)
   //m4+dmem(32, 32, $reset, $addr[4:0], $wr_en, $wr_data[31:0], $rd_en, $rd_data)
   m4+cpu_viz()
\SV
   endmodule

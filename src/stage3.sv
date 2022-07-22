`timescale 1ns/10ps

module stage3 (clk, reset, halt, instr_2, pcP4_2, pc_2, rdata1_2, rdata2_2, rdata_2, 
                instr_o_ff, data_o_ff, data2_o_ff, csrData_o_ff, pc_o, offset_br_o, 
                data_o, csrData_o, regWrite_o, csrWrite_o, branch_o, rd_o, csr_Addr_o);

    input logic clk, reset, halt;
    input logic [31:0] instr_2, pcP4_2, pc_2, rdata1_2, rdata2_2, rdata_2;
    output logic [31:0] instr_o_ff, data_o_ff, data2_o_ff, csrData_o_ff, pc_o, offset_br_o;
    output logic [31:0] data_o, csrData_o;
    output logic regWrite_o, csrWrite_o, branch_o;
    output logic [4:0] rd_o;
    output logic [5:0] csr_Addr_o;

    assign rd_o = instr_2[11:7];
    assign csr_Addr_o = instr_2[25:20];

    logic [4:0] opcode;
    logic [2:0] opcode1;
    logic opcode2;

    assign opcode = instr_2[6:2];
    assign opcode1 = instr_2[14:12];
    assign opcode2 = instr_2[30];

    logic [31:0] pcimm, imm, uimm, imm_store, offset_jal;
    logic [4:0] shamt;
    assign pcimm = {instr_2[31:12], 12'b0};
    assign imm = {{20{instr_2[31]}}, instr_2[31:20]};
    assign uimm = {27'b0, instr_2[19:15]};
    assign imm_store = {{20{instr_2[31]}}, instr_2[31:25], instr_2[11:7]};
    assign shamt = instr_2[24:20];
    assign offset_br_o = {{20{instr_2[31]}}, instr_2[7], instr_2[30:25], instr_2[11:8], 1'b0};
    assign offset_jal = {{12{instr_2[31]}}, instr_2[19:12], instr_2[20], instr_2[30:21], 1'b0};

    
    logic [31:0] aluInA, aluInB, sum;
    logic cin, cf, of, zf, nf;

    ksa_top alu (.a(aluInA), .b(aluInB), .cin(cin), .carryOut(cf), .overflow(of), .zero(zf), .neg(nf), .sum(sum));

    always_comb begin
        casex ({opcode2, opcode1, opcode})
            9'bxxxx01101: begin         //lui
                aluInA = 32'bx; aluInB = 32'bx; data_o = pcimm; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bxxxx00101: begin         //auipc
                aluInA = pc_2; aluInB = pcimm; data_o = sum; csrData_o = 32'bx; cin = 1'b0;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx00000100: begin         //addi
                aluInA = rdata1_2; aluInB = imm; data_o = sum; csrData_o = 32'bx; cin = 1'b0;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx01000100: begin         //slti
                aluInA = rdata1_2; aluInB = imm; data_o = {31'b0, nf^of}; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx01100100: begin         //sltiu
                aluInA = rdata1_2; aluInB = imm; data_o = {31'b0, ~cf}; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx10000100: begin         //xori
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 ^ rdata2_2; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx11000100: begin         //ori
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 | rdata2_2; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx11100100: begin         //andi
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 & imm; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx00100100: begin         //slli
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 << shamt; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'b010100100: begin         //srli
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 >> shamt; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'b110100100: begin         //srai
                aluInA = 32'bx; aluInB = 32'bx; data_o = $signed(rdata1_2) >>> shamt; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'b000001100: begin         //add
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = sum; csrData_o = 32'bx; cin = 1'b0;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'b100001100: begin         //sub
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = sum; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx00101100: begin         //sll
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 << rdata2_2[4:0]; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx01001100: begin         //slt
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = {31'b0, nf^of}; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx01101100: begin         //sltu
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = {31'b0, ~cf}; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx10001100: begin         //xor
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 ^ rdata2_2; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'b010101100: begin         //srl
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 >> rdata2_2[4:0]; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'b110101100: begin         //sra
                aluInA = 32'bx; aluInB = 32'bx; data_o = $signed(rdata1_2) >>> rdata2_2[4:0]; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx11001100: begin         //or
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 | rdata2_2; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bx11101100: begin         //and
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata1_2 & rdata2_2; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end

            9'bx00011000: begin         //beq
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = 32'bx; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; branch_o = zf;
            end
            9'bx00111000: begin         //bne
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = 32'bx; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; branch_o = ~zf;
            end
            9'bx10011000: begin         //blt
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = 32'bx; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; branch_o = nf^of;
            end
            9'bx10111000: begin         //bge
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = 32'bx; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; branch_o = ~(nf^of);
            end
            9'bx11011000: begin         //bltu
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = 32'bx; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; branch_o = ~cf;
            end
            9'bx11111000: begin         //bgeu
                aluInA = rdata1_2; aluInB = rdata2_2; data_o = 32'bx; csrData_o = 32'bx; cin = 1'b1;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; branch_o = cf;
            end
            9'bxxxx11011: begin         //jal
                aluInA = pc_2; aluInB = offset_jal; data_o = pcP4_2; csrData_o = 32'bx; cin = 1'b0;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
            9'bxxxx11001: begin         //jalr
                aluInA = rdata1_2; aluInB = imm; data_o = pcP4_2; csrData_o = 32'bx; cin = 1'b0;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end


            9'bxxxx00000: begin         //lb, lh, lw, lbu, lhu
                aluInA = rdata1_2; aluInB = imm; data_o = sum; csrData_o = 32'bx; cin = 1'b0;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; branch_o = 1'bx;
            end


            9'bxxxx01000: begin         //sb, sh, sw
                aluInA = rdata1_2; aluInB = imm_store; data_o = sum; csrData_o = 32'bx; cin = 1'b0;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; branch_o = 1'bx;
            end


            9'bx00111100: begin         //csrrw
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata_2; csrData_o = rdata1_2; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b1; branch_o = 1'bx;
            end
            9'bx01011100: begin         //csrrs
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata_2; csrData_o = rdata_2 | rdata1_2; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b1; branch_o = 1'bx;
            end
            9'bx01111100: begin         //csrrc
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata_2; csrData_o = rdata_2 & ~rdata1_2; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b1; branch_o = 1'bx;
            end
            9'bx10111100: begin         //csrrwi
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata_2; csrData_o = uimm; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b1; branch_o = 1'bx;
            end
            9'bx11011100: begin         //csrrsi
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata_2; csrData_o = rdata_2 | uimm; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b1; branch_o = 1'bx;
            end
            9'bx11111100: begin         //csrrci
                aluInA = 32'bx; aluInB = 32'bx; data_o = rdata_2; csrData_o = rdata_2 & ~uimm; cin = 1'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b1; branch_o = 1'bx;
            end


            default: begin
                aluInA = 32'bx; aluInB = 32'bx; data_o = 32'bx; csrData_o = 32'bx; cin = 1'bx;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; branch_o = 1'bx;
            end
        endcase

        casex ({opcode2, opcode1, opcode})
            9'bxxxx11011: begin         //jal
                pc_o = sum;
            end
            9'bxxxx11001: begin         //jalr
                pc_o = {sum[31:1], 1'b0}; 
            end
            default: pc_o = 32'bx;
        endcase
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            instr_o_ff <= 32'b00000000000000000000000000110011;
            data_o_ff <= 32'bx;
            data2_o_ff <= 32'bx;
            csrData_o_ff <= 32'bx;
        end
        else if (halt) begin
            instr_o_ff <= instr_o_ff;
            data_o_ff <= data_o_ff;
            data2_o_ff <= data2_o_ff;
            csrData_o_ff <= csrData_o_ff;
        end
        else begin
            instr_o_ff <= instr_2;
            data_o_ff <= data_o;
            data2_o_ff <= rdata2_2;
            csrData_o_ff <= csrData_o;
        end
    end
endmodule
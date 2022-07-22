`timescale 1ns/10ps


module cpu(clk, reset, interrupt);
    input logic clk, reset, interrupt;

    logic halt_whole;

    logic halt_wfi, instrMemRdy, Memrdy, branch;
    logic [31:0] brOffset, jalPC, instr_1_2, pcP4_1_2, pc_1_2, data_3_2, data_4_2, data_5_2;
    logic [31:0] csrData_3_2, csrData_4_2, csrData_5_2;
    logic [4:0] rd_3_2, rd_4_2, rd_5_2;
    logic [5:0] csr_Addr_3_2, csr_Addr_4_2, csr_Addr_5_2;
    logic regWrite_3_2, regWrite_4_2, regWrite_5_2;
    logic csrWrite_3_2, csrWrite_4_2, csrWrite_5_2;
    logic [31:0] instr_2_3, instr_3_4, instr_4_5;
    logic [31:0] rdata_2_3, rdata1_2_3, rdata2_2_3, pcP4_2_3, pc_2_3;
    logic [31:0] data_3_4, data2_3_4, csrData_3_4;
    logic [31:0] data_4_5, csrData_4_5;

    assign halt_whole = halt_wfi | ~instrMemRdy | ~Memrdy;

    stage1 s1 (.clk(clk), .reset(reset), .interrupt(interrupt), .halt(halt_whole), 
               .branch(branch), .brOffset(brOffset), .jalPC(jalPC), .instrMemRdy(instrMemRdy),
               .instr_o(instr_1_2), .pcP4_o(pcP4_1_2), .pc_o(pc_1_2), .halt_wfi(halt_wfi));

    stage2 s2 (.clk(clk), .reset(reset), .halt(halt_whole), .instr_1(instr_1_2), .pcP4_1(pcP4_1_2), .pc_1(pc_1_2), 
               .data_3(data_3_2), .data_4(data_4_2), .data_5(data_5_2), .csrData_3(csrData_3_2), .csrData_4(csrData_4_2), .csrData_5(csrData_5_2), 
               .rd_3(rd_3_2), .rd_4(rd_4_2), .rd_5(rd_5_2), .csr_Addr_3(csr_Addr_3_2), .csr_Addr_4(csr_Addr_4_2), .csr_Addr_5(csr_Addr_5_2), 
                .regWrite_3(regWrite_3_2), .regWrite_4(regWrite_4_2), .regWrite_5(regWrite_5_2), .csrWrite_3(csrWrite_3_2), .csrWrite_4(csrWrite_4_2), .csrWrite_5(csrWrite_5_2), 
                .instr_o(instr_2_3), .rdata_o(rdata_2_3), .rdata1_o(rdata1_2_3), .rdata2_o(rdata2_2_3), .pcP4_o(pcP4_2_3), .pc_o(pc_2_3));

    stage3 s3 (.clk(clk), .reset(reset), .halt(halt_whole), .instr_2(instr_2_3), .pcP4_2(pcP4_2_3), .pc_2(pc_2_3), .rdata1_2(rdata1_2_3), .rdata2_2(rdata2_2_3), .rdata_2(rdata_2_3), 
                .instr_o_ff(instr_3_4), .data_o_ff(data_3_4), .data2_o_ff(data2_3_4), .csrData_o_ff(csrData_3_4), .pc_o(jalPC), .offset_br_o(brOffset), 
                .data_o(data_3_2), .csrData_o(csrData_3_2), .regWrite_o(regWrite_3_2), .csrWrite_o(csrWrite_3_2), .branch_o(branch), .rd_o(rd_3_2), .csr_Addr_o(csr_Addr_3_2));

    stage4 s4 (.clk(clk), .reset(reset), .halt(halt_whole), .instr_3(instr_3_4), .data1_3(data_3_4), .data2_3(data2_3_4), .csrdata_3(csrData_3_4), .instr_o_ff(instr_4_5), 
                .data_o_ff(data_4_5), .csrData_o_ff(csrData_4_5), .data_o(data_4_2), .csrData_o(csrData_4_2), .rd_o(rd_4_2), .csr_Addr_o(csr_Addr_4_2), 
                .regWrite_o(regWrite_4_2), .csrWrite_o(csrWrite_4_2), .Memrdy(Memrdy));

    stage5 s5 (.instr_4(instr_4_5), .data_4(data_4_5), .csrdata_4(csrData_4_5), .data_o(data_5_2), .csrData_o(csrData_5_2), .regWrite_o(regWrite_5_2), 
               .csrWrite_o(csrWrite_5_2), .rd_o(rd_5_2), .csr_Addr_o(csr_Addr_5_2));


endmodule

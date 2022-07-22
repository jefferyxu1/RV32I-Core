`timescale 1ns/10ps

module stage2 (clk, reset, halt, instr_1, pcP4_1, pc_1, 
                data_3, data_4, data_5, csrData_3, csrData_4, csrData_5, 
                rd_3, rd_4, rd_5, csr_Addr_3, csr_Addr_4, csr_Addr_5, 
                regWrite_3, regWrite_4, regWrite_5, csrWrite_3, csrWrite_4, csrWrite_5, 
                instr_o, rdata_o, rdata1_o, rdata2_o, pcP4_o, pc_o);

    
    input logic clk, reset, halt;
    input logic [31:0] instr_1, pcP4_1, pc_1, data_3, data_4, data_5, csrData_3, csrData_4, csrData_5;
    input logic [4:0] rd_3, rd_4, rd_5;
    input logic [5:0] csr_Addr_3, csr_Addr_4, csr_Addr_5;
    input logic regWrite_3, regWrite_4, regWrite_5, csrWrite_3, csrWrite_4, csrWrite_5;
    output logic [31:0] instr_o, rdata_o, rdata1_o, rdata2_o, pcP4_o, pc_o;

    logic [4:0] opcode, rs1, rs2, rd;
    logic [5:0] csr_Addr;
    logic [31:0] instr, rdata1, rdata2, rdata, data_reg1, data_reg2, data_csr;

    assign opcode = instr_1[6:2];
    assign rd = instr_1[11:7];
    assign rs1 = instr_1[19:15];
    assign rs2 = instr_1[24:20];
    assign csr_Addr = instr_1[25:20];

    regfile regfile (.clk(clk), .reset(reset), .writeEn(regWrite_5), .waddr(rd_5), .wdata(data_5), .rs1(rs1), .rdata1(data_reg1), .rs2(rs2), .rdata2(data_reg2));

    csrfile csrfile (.clk(clk), .reset(reset), .writeEn(csrWrite_5), .waddr(csr_Addr_5), .wdata(csrData_5), .raddr(csr_Addr), .rdata(data_csr));

    always_comb begin
        if (regWrite_3 && rs1 == rd_3 && rs1 != 5'b0) begin
            rdata1 = data_3;
        end
        else if (regWrite_4 && rs1 == rd_4 && rs1 != 5'b0) begin
            rdata1 = data_4;
        end
        else if (regWrite_5 && rs1 == rd_5 && rs1 != 5'b0) begin
            rdata1 = data_5;
        end
        else begin
            rdata1 = data_reg1;
        end

        if (regWrite_3 && rs2 == rd_3 && rs2 != 5'b0) begin
            rdata2 = data_3;
        end
        else if (regWrite_4 && rs2 == rd_4 && rs2 != 5'b0) begin
            rdata2 = data_4;
        end
        else if (regWrite_5 && rs2 == rd_5 && rs2 != 5'b0) begin
            rdata2 = data_5;
        end
        else begin
            rdata2 = data_reg2;
        end

        if (csrWrite_3 && csr_Addr == rd_3) begin
            rdata = csrData_3;
        end
        else if (csrWrite_4 && csr_Addr == rd_4) begin
            rdata = csrData_4;
        end
        else if (csrWrite_5 && csr_Addr == rd_5) begin
            rdata = csrData_5;
        end
        else begin
            rdata = data_csr;
        end
    end


    always_ff @( posedge clk ) begin
        if (reset) begin
            instr_o <= 32'b00000000000000000000000000110011;
            rdata_o <= 32'bx;
            rdata1_o <= 32'bx;
            rdata2_o <= 32'bx;
            pcP4_o <= 32'bx;
            pc_o <= 32'bx;
        end
        else if (halt) begin
            instr_o <= instr_o;
            rdata_o <= rdata_o;
            rdata1_o <= rdata1_o;
            rdata2_o <= rdata2_o;
            pcP4_o <= pcP4_o;
            pc_o <= pc_o;
        end
        else begin
            instr_o <= instr_1;
            rdata_o <= rdata;
            rdata1_o <= rdata1;
            rdata2_o <= rdata2;
            pcP4_o <= pcP4_1;
            pc_o <= pc_1;
        end
    end

endmodule

`timescale 1ns/10ps

module stage5 (instr_4, data_4, csrdata_4, data_o, csrData_o, regWrite_o, csrWrite_o, rd_o, csr_Addr_o);
    input logic [31:0] instr_4, data_4, csrdata_4;
    output logic [31:0] data_o, csrData_o;
    output logic regWrite_o, csrWrite_o;
    output logic [4:0] rd_o;
    output logic [5:0] csr_Addr_o;

    logic [4:0] opcode;
    logic [2:0] opcode1;
    logic opcode2;
    assign rd_o = instr_4[11:7];
    assign csr_Addr_o = instr_4[25:20];

    assign opcode = instr_4[6:2];
    assign opcode1 = instr_4[14:12];
    assign opcode2 = instr_4[30];

    assign data_o = data_4;
    assign csrData_o = csrdata_4;

    always_comb begin
        casex ({opcode2, opcode1, opcode})
            9'bxxxx01101: begin         //lui
                regWrite_o = 1'b1; csrWrite_o = 1'b0;
            end
            9'bxxxx00101: begin         //auipc
                regWrite_o = 1'b1; csrWrite_o = 1'b0;
            end
            9'bxxxx00100: begin         //addi
                regWrite_o = 1'b1; csrWrite_o = 1'b0;
            end
            9'bxxxx01100: begin         //add
                regWrite_o = 1'b1; csrWrite_o = 1'b0;
            end

            9'bxxxx11000: begin         //beq
                regWrite_o = 1'b0; csrWrite_o = 1'b0;
            end
            9'bxxxx11011: begin         //jal
                regWrite_o = 1'b1; csrWrite_o = 1'b0;
            end
            9'bxxxx11001: begin         //jalr
                regWrite_o = 1'b1; csrWrite_o = 1'b0;
            end


            9'bxxxx00000: begin         //lb, lh, lw, lbu, lhu
                regWrite_o = 1'b1; csrWrite_o = 1'b0;
            end


            9'bxxxx01000: begin         //sb, sh, sw
                regWrite_o = 1'b0; csrWrite_o = 1'b0;
            end


            9'bxxxx11100: begin         //csrrw
                regWrite_o = 1'b1; csrWrite_o = 1'b1;
            end

            
            default: begin
                regWrite_o = 1'b0; csrWrite_o = 1'b0;
            end
        endcase
    end


endmodule

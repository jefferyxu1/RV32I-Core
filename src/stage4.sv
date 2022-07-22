`timescale 1ns/10ps

module stage4 (clk, reset, halt, instr_3, data1_3, data2_3, csrdata_3, instr_o_ff, 
                data_o_ff, csrData_o_ff, data_o, csrData_o, rd_o, csr_Addr_o, 
                regWrite_o, csrWrite_o, Memrdy);

    input logic clk, reset, halt;
    input logic [31:0] instr_3, data1_3, data2_3, csrdata_3;
    output logic [31:0] instr_o_ff, data_o_ff, csrData_o_ff, data_o, csrData_o;
    output logic [4:0] rd_o;
    output logic [5:0] csr_Addr_o;
    output logic regWrite_o, csrWrite_o, Memrdy;

    logic [4:0] opcode;
    logic [2:0] opcode1;
    logic opcode2;

    assign rd_o = instr_3[11:7];
    assign csr_Addr_o = instr_3[25:20];

    assign opcode = instr_3[6:2];
    assign opcode1 = instr_3[14:12];

    logic [31:0] addr, wrData, rdData;
    logic wrEn, rdEn;
    logic [2:0] xfer;

    datamem dm (.address(addr), .write_enable(wrEn), .read_enable(rdEn), .write_data(wrData), 
                .clk(clk), .xfer_size(xfer), .read_data(rdData), .MemRdy(Memrdy));


    always_comb begin
        casex ({opcode1, opcode})
            
            8'b00000000: begin         //lb
                addr = data1_3; data_o = 32'(signed'(rdData[7:0])); xfer = 3'b001; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b1; wrData = 32'bx;
            end

            8'b00100000: begin         //lh
                addr = data1_3; data_o = 32'(signed'(rdData[15:0])); xfer = 3'b010; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b1; wrData = 32'bx;
            end

            8'b01000000: begin         //lw
                addr = data1_3; data_o = 32'(signed'(rdData[31:0])); xfer = 3'b100; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b1; wrData = 32'bx;
            end

            8'b10000000: begin         //lbu
                addr = data1_3; data_o = 32'(unsigned'(rdData[7:0])); xfer = 3'b001; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b1; wrData = 32'bx;
            end

            8'b10100000: begin         //lhu
                addr = data1_3; data_o = 32'(unsigned'(rdData[15:0])); xfer = 3'b010; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b1; wrData = 32'bx;
            end


            8'b00001000: begin         //sb
                addr = data1_3; data_o = 32'bx; xfer = 3'b001; csrData_o = 32'bx;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; wrEn = 1'b1; rdEn = 1'b0; wrData = 32'(unsigned'(data2_3[7:0]));
            end

            8'b00101000: begin         //sh
                addr = data1_3; data_o = 32'bx; xfer = 3'b010; csrData_o = 32'bx;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; wrEn = 1'b1; rdEn = 1'b0; wrData = 32'(unsigned'(data2_3[15:0]));
            end

            8'b01001000: begin         //sw
                addr = data1_3; data_o = 32'bx; xfer = 3'b100; csrData_o = 32'bx;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; wrEn = 1'b1; rdEn = 1'b0; wrData = 32'(unsigned'(data2_3[31:0]));
            end


            8'bxxx01101, 8'bxxx00101: begin         //lui auipc
                addr = 32'bx; data_o = data1_3; xfer = 3'bx; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b0; wrData = 32'bx;
            end
            8'bxxx00100: begin         //00100 instr
                addr = 32'bx; data_o = data1_3; xfer = 3'bx; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b0; wrData = 32'bx;
            end
            8'bxxx01100: begin         //01100 instr
                addr = 32'bx; data_o = data1_3; xfer = 3'bx; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b0; wrData = 32'bx;
            end


            8'bxxx11011: begin         //jal
                addr = 32'bx; data_o = data1_3; xfer = 3'bx; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b0; wrData = 32'bx;
            end
            8'bxxx11001: begin         //jalr
                addr = 32'bx; data_o = data1_3; xfer = 3'bx; csrData_o = 32'bx;
                regWrite_o = 1'b1; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b0; wrData = 32'bx;
            end



            8'bxxx11100: begin         //csr instr
                addr = 32'bx; data_o = data1_3; xfer = 3'bx; csrData_o = csrdata_3;
                regWrite_o = 1'b1; csrWrite_o = 1'b1; wrEn = 1'b0; rdEn = 1'b0; wrData = 32'bx;
            end


            default: begin
                addr = 32'bx; data_o = 32'bx; xfer = 3'bx; csrData_o = 32'bx;
                regWrite_o = 1'b0; csrWrite_o = 1'b0; wrEn = 1'b0; rdEn = 1'b0; wrData = 32'bx;
            end
        endcase
    end

    always_ff @( posedge clk ) begin
        if (reset) begin
            instr_o_ff <= 32'b00000000000000000000000000110011;
            data_o_ff <= 32'bx;
            csrData_o_ff <= 32'bx;
        end
        else if (halt) begin
            instr_o_ff <= instr_o_ff;
            data_o_ff <= data_o_ff;
            csrData_o_ff <= csrData_o_ff;
        end
        else begin
            instr_o_ff <= instr_3;
            data_o_ff <= data_o;
            csrData_o_ff <= csrData_o;
        end
    end

endmodule

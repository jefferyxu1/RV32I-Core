`timescale 1ns/10ps


`define DATA_MEM_SIZE	64
    
module datamem (
    input logic		[31:0]	address,
    input logic		write_enable,
    input logic		read_enable,
    input logic		[31:0]	write_data,
    input logic		clk,
    input logic		[2:0]	xfer_size,
    output logic	[31:0]	read_data,
    output logic    MemRdy
    );

    assign MemRdy = 1'b1;

    logic [7:0] mem [`DATA_MEM_SIZE-1:0];
    logic [31:0] aligned_address;

    always_comb begin
        case (xfer_size)
            3'd1: aligned_address = address;
            3'd2: aligned_address = {address[31:1], 1'b0};
            3'd4: aligned_address = {address[31:2], 2'b00};
        default: aligned_address = {address[31:2],2'b00}; // Bad addresses forced to double-word aligned.
        endcase
    end

    always_comb begin
        case (xfer_size)
        3'd1: read_data = {24'b0, mem[aligned_address]};
        3'd2: read_data = {16'b0, mem[aligned_address + 1], mem[aligned_address]};
        3'd4: read_data = {mem[aligned_address + 3], mem[aligned_address + 2], 
                        mem[aligned_address + 1], mem[aligned_address]}; 
        endcase
    end

    always_ff @(posedge clk) begin
        if (write_enable)
            case(xfer_size)
                3'd1: mem[aligned_address] <= write_data[7:0];
                3'd2: begin
                    mem[aligned_address] <= write_data[7:0];
                    mem[aligned_address + 1] <= write_data[15:8];
                end
                3'd4: begin
                    mem[aligned_address] <= write_data[7:0];
                    mem[aligned_address + 1] <= write_data[15:8];
                    mem[aligned_address + 2] <= write_data[23:16];
                    mem[aligned_address + 3] <= write_data[31:24];
                end
            endcase
    end

endmodule

`timescale 1ns/10ps

module regfile (
    input wire clk,
    input wire reset,
    input wire writeEn,
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    input wire [4:0] rs1,
    output wire [31:0] rdata1,
    input wire [4:0] rs2,
    output wire [31:0] rdata2
);

    reg [31:0] regs [0:31];
    wire [31:0] regs_out [0:31];
    
    assign regs_out[0] = 32'b0;

    genvar i;
    for (i = 1; i < 32; i = i+1) begin
        assign regs_out[i] = regs[i];
    end

    // write
    always_ff @(posedge clk) begin
        if (reset) begin
            integer i;
            for (i = 0; i < 32; i = i+1) begin
                regs[i] <= 32'b0;
            end
        end else if (writeEn) begin
            regs[waddr] <= wdata;
        end
    end

    // read
    assign rdata1 = regs_out[rs1];
    assign rdata2 = regs_out[rs2];

endmodule

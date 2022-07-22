`timescale 1ns/10ps


module csrfile (
    input wire clk,
    input wire reset,
    input wire writeEn,
    input wire [5:0] waddr,
    input wire [31:0] wdata,
    input wire [5:0] raddr,
    output wire [31:0] rdata
);

    reg [31:0] regs [0:63];

    // write
    always_ff @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < 64; i = i+1) begin
                regs[i] <= 32'b0;
            end
        end
        if (writeEn) begin
            regs[waddr] <= wdata;
        end
    end

    // read
    assign rdata = regs[raddr];

endmodule

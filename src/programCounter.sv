`timescale 1ns/10ps

module programCounter (clk, reset, halt, newPC, currPC);
    input logic clk, reset, halt;
    input logic [31:0] newPC;
    output logic [31:0] currPC;

    logic [31:0] PCstorage;

    always_ff @(posedge clk) begin
        if (reset) PCstorage <= 32'b0;
        else if (halt) PCstorage <= PCstorage;
        else PCstorage <= newPC;
    end

    assign currPC = PCstorage;

endmodule

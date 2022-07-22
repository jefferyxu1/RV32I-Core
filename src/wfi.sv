`timescale 1ns/10ps

module wfi(clk, reset, trigger, halt, interrupt);
    input logic clk, reset, trigger, interrupt;
    output logic halt;

    logic ps, ns;
    
    always_comb begin
        case (ps)
            1'b0: ns = trigger ? 1'b1 : 1'b0;
            1'b1: ns = interrupt ? 1'b0 : 1'b1;
            default: ns = ps;
        endcase
    end
    
    always_ff @( posedge clk ) begin
        if (reset) begin
           ps <= 0; 
        end
        else begin
            ps <= ns;
        end
    end

    assign halt = ps;
endmodule

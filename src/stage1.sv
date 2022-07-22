`timescale 1ns/10ps

module stage1 (clk, reset, interrupt, halt, branch, brOffset, jalPC, instrMemRdy, instr_o, pcP4_o, pc_o, halt_wfi);
    input logic clk, reset, interrupt, halt, branch;
    input logic [31:0] brOffset, jalPC;
    output logic instrMemRdy;
    output logic [31:0] instr_o, pcP4_o, pc_o;
    output logic halt_wfi;

    logic [31:0] pc, newPC, pcP4, instr, brPC, instr_sel;
    logic [2:0] BrJalLoad, BrJalLoad_n, BrJalLoad_n_n;
    logic trigger;
    logic [2:0] newPC_case;
    logic counter_halt, counter_halt_n;
    assign newPC_case = BrJalLoad_n_n & {branch, 2'b11};

    assign trigger = ({instr_sel[14:12], instr_sel[6:2]} == 8'b00011100);

    assign counter_halt = BrJalLoad[2] | BrJalLoad[1] | BrJalLoad[0] | BrJalLoad_n[2] | BrJalLoad_n[1];
    assign counter_halt_n = BrJalLoad_n[2] | BrJalLoad_n[1] | BrJalLoad_n[0] | BrJalLoad_n_n[2] | BrJalLoad_n_n[1];

    programCounter pCounter (.clk(clk), .reset(reset), .halt(halt | counter_halt), .newPC(newPC), .currPC(pc));

    instructmem instrMem (.address(pc), .instruction(instr), .instrMemRdy(instrMemRdy), .clk(clk));

    ksa_top adder1 (.a(pc), .b(32'd4), .cin(1'b0), .carryOut(), .overflow(), .zero(), .neg(), .sum(pcP4));

    ksa_top adder2 (.a(pc), .b(brOffset), .cin(1'b0), .carryOut(), .overflow(), .zero(), .neg(), .sum(brPC));

    wfi wfiModule (.clk(clk), .reset(reset), .trigger(trigger), .halt(halt_wfi), .interrupt(interrupt));

    always_comb begin
        casex (newPC_case)
            3'b010: newPC = jalPC;
            3'b100: newPC = brPC;
            default: newPC = pcP4;
        endcase

        case (counter_halt_n | trigger)
            1'b0: instr_sel = instr;
            1'b1: instr_sel = 32'b00000000000000000000000000110011;
            default: instr_sel = instr;
        endcase

        case (instr_sel[6:2])
            5'b11011: BrJalLoad = 3'b010;
            5'b11001: BrJalLoad = 3'b010;
            5'b11000: BrJalLoad = 3'b100;
            5'b00000: BrJalLoad = 3'b001;
            default: BrJalLoad = 3'b000;
        endcase

    end


    always_ff @(posedge clk) begin
        if (reset) begin
            instr_o <= 32'b00000000000000000000000000110011;
            pcP4_o <= 32'd4;
            pc_o <= 32'b0;
            BrJalLoad_n <= 3'b000;
            BrJalLoad_n_n <= 3'b000;
        end
        else if (halt) begin
            instr_o <= instr_o;
            pcP4_o <= pcP4_o;
            pc_o <= pc_o;
            BrJalLoad_n <= BrJalLoad_n;
            BrJalLoad_n_n <= BrJalLoad_n_n;
        end
        else begin
            instr_o <= instr_sel;
            pcP4_o <= pcP4;
            pc_o <= pc;
            BrJalLoad_n <= BrJalLoad;
            BrJalLoad_n_n <= BrJalLoad_n;
        end

    end
endmodule

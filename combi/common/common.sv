// Resettable flip flop
module flopr #(parameter WIDTH = 8)
              (input logic clk, reset,
               input logic [WIDTH-1:0] d,
               output logic [WIDTH-1:0] q);

always_ff @(posedge clk)
  if (reset) q <= 0;
  else q <= d;

endmodule

// Resettable flip flop with enable
module flopenr #(parameter WIDTH = 8)
                (input logic clk, reset, en,
                 input logic [WIDTH-1:0] d,
                 output logic [WIDTH-1:0] q);

always_ff @(posedge clk)
  if (reset) q <= 0;
  else if (en) q <= d;

endmodule

// 2-1 mux
module mux2 #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0] d0, d1,
              input logic s,
              output logic [WIDTH-1:0] y);

assign y = s ? d1 : d0;

endmodule

// 3-1 mux
module mux3 #(parameter WIDTH = 8)
             (input logic [WIDTH-1:0] d0, d1, d2,
              input logic [1:0] s,
              output logic [WIDTH-1:0] y);

always_comb
  case(s)
    2'b00: y = d0;
    2'b01: y = d1;
    2'b10: y = d2;
    default: y = 'bx;
  endcase

endmodule

module apbslave
#(
  addrWidth = 8,
  dataWidth = 32
)
(
  input                        clk,
  input                        n_rst,
  input        [addrWidth-1:0] paddr,
  input                        pwrite,
  input                        psel,
  input                        penable,
  input        [dataWidth-1:0] pwdata,
  output logic [dataWidth-1:0] prdata
);

logic [dataWidth-1:0] mem [18];

logic [1:0] apb_st;
const logic [1:0] SETUP = 0;
const logic [1:0] W_ENABLE = 1;
const logic [1:0] R_ENABLE = 2;

// SETUP -> ENABLE
always @(posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
    apb_st <= 0;
    prdata <= 0;
  end

  else begin
    case (apb_st)
      SETUP : begin
        prdata <= 0;

        if (psel && !penable) begin
          if (pwrite) begin
            apb_st <= W_ENABLE;
          end

          else begin
            apb_st <= R_ENABLE;
          end
        end
      end

      W_ENABLE : begin
        if (psel && penable && pwrite) begin
          mem[paddr] <= pwdata;
        end

        apb_st <= SETUP;
      end

      R_ENABLE : begin
        if (psel && penable && !pwrite) begin
          prdata <= mem[paddr];
        end

        apb_st <= SETUP;
      end
    endcase
  end
end 


endmodule

`timescale 1 ns / 1 ns
`define MEM_SIZE 128

module tb_tangnano20kdock
  ();

   integer i;

   // inputs
   logic sys_clk = 1'b0;
   logic ser_rx = 1'b1;
   logic btn1 = 1'b0;

   // outputs
   logic ser_tx;
   logic [5:0] led_n;

   // 4MHz clock here should give a 1us micro cycle
   always
     #125 sys_clk = ~sys_clk;


   initial
     begin
        $dumpvars();
        @(negedge sys_clk);
        btn1 = 1'b1;
        for (i = 0; i < 10; i = i + 1)
          @(negedge sys_clk);
        btn1 = 1'b0;
        #(1000*1000*50); // 50ms
        $finish;
     end


   tangnano20kdock dut
   (
    .sys_clk(sys_clk),
    .btn1(btn1),
    .ser_rx(ser_rx),
    .ser_tx(ser_tx),
    .led_n(led_n)
    );

endmodule

module rPLL
  #(      parameter

        FCLKIN = 0,
        IDIV_SEL = 0,
        FBDIV_SEL = 0,
        DYN_SDIV_SEL = 0,
        ODIV_SEL = 0
          )
     (
      input       CLKIN,
      input       CLKFB,
      input       RESET,
      input       RESET_P,

      input [5:0] FBDSEL,
      input [5:0] IDSEL,
      input [5:0] ODSEL,
      input [3:0] PSDA,
      input [3:0] DUTYDA,
      input [3:0] FDLY,

      output      CLKOUT,
      output      CLKOUTP,
      output      CLKOUTD3,
      output      CLKOUTD,
      output      LOCK
      );

   logic [1:0] counter = 2'b00;

   always_ff@(posedge CLKIN)
     begin
        counter <= counter + 1;
     end

   assign CLKOUTD = counter[1];
   assign CLKOUTD3  = counter[0];
   assign LOCK = 1'b1;


endmodule

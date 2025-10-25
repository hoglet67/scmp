`timescale 1 ns / 1 ns
`define MEM_SIZE 128

module tangnano20kdock
  #(      parameter C_SIZE = 12,
          SIM = 0
          )
   (
    input        sys_clk,
    input        btn1,
    input        ser_rx,
    output       ser_tx,
    output [5:0] led_n
    );


   logic         rst_n;
   logic         clk_1m;
   logic         cpu_clk;
   logic         ram_clk;
   logic         pll_lock;

   logic [7:0]        cpu_D_i;
   logic              cpu_sb;
   logic              cpu_sa;

   logic [3:0]        cpu_addr_latched;
   logic [11:0]       cpu_addr;
   logic [7:0]        cpu_D_o;
   logic              cpu_f0;
   logic              cpu_f1;
   logic              cpu_f2;

   logic              cpu_ADS_n;
   logic              cpu_RD_n;
   logic              cpu_WR_n;

   logic              cpu_rst_n;

   logic [7:0]        int_rom_D_Q;
   logic [7:0]        int_ram_D_Q;
   logic [7:0]        ext_ram_D_Q;

   logic [7:0]        int_rom[0:4095];

   logic [7:0]        int_ram[0:63];

   logic [7:0]        ext_ram[0:4095];


   initial begin
      $readmemh("8060nibl_2400baud_putcfixed_hacked.mi", int_rom);
      // $readmemh("8060nibl_2400baud_putcfixed.mi", int_rom);
      // $readmemh("8060nibl_2400baud.mi", int_rom);
      // $readmemh("8060nibl.mi", int_rom);
      // $readmemh("8073nibl.mi", int_rom);
   end

   always_ff@(posedge ram_clk)
     begin
        int_rom_D_Q <= int_rom[cpu_addr];
     end


   always_ff@(posedge ram_clk)
     begin
        int_ram_D_Q <= int_ram[cpu_addr[5:0]];
        if (!cpu_WR_n & cpu_addr[11:6] == 6'b111111 & cpu_addr_latched == 4'hf)
          int_ram[cpu_addr[5:0]] <= cpu_D_o;
     end

   always_ff@(posedge ram_clk)
     begin
        ext_ram_D_Q <= ext_ram[cpu_addr];
        if (!cpu_WR_n & cpu_addr_latched == 4'h1)
          ext_ram[cpu_addr] <= cpu_D_o;
     end

   always_comb begin
      if (!cpu_RD_n)
        if (cpu_addr_latched == 4'h0)
          cpu_D_i <= int_rom_D_Q;
        else if (cpu_addr_latched == 4'h1)
          cpu_D_i <= ext_ram_D_Q;
        else if (cpu_addr[11:6] == 6'b111111 & cpu_addr_latched == 4'hf)
          cpu_D_i <= int_ram_D_Q;
        else if (cpu_addr == 12'hd00 & cpu_addr_latched == 4'hf)
          cpu_D_i <= 8'h80;
        else
          cpu_D_i <= 8'hff;
      else
        cpu_D_i <= 8'bZZZZZZZZ;
   end

   assign rst_n = ~btn1;
   assign cpu_rst_n = rst_n & pll_lock;
   assign ser_tx = !cpu_f0;
   assign cpu_sb_i = ser_rx;
   assign cpu_sa_i = 1'b0;

   scmp cpu
     (
      .rst_n(cpu_rst_n),
      .clk(cpu_clk),
      .D_i(cpu_D_i),
      .sb(cpu_sb_i),
      .sa(cpu_sa_i),
      .addr(cpu_addr),
      .D_o(cpu_D_o),
      .f0(cpu_f0),
      .f1(cpu_f1),
      .f2(cpu_f2),
      .sin(1'b0),
      .sout(),

      .ADS_n(cpu_ADS_n),
      .RD_n(cpu_RD_n),
      .WR_n(cpu_WR_n)
      );


   always_ff@(posedge ram_clk)
     begin
        if (!cpu_ADS_n)
          cpu_addr_latched <= cpu_D_o[3:0];
     end

   logic   flag_h;
   logic   flag_d;
   logic   flag_i;
   logic   flag_r;

   always@(posedge cpu_clk, negedge rst_n) begin
      if (!rst_n)
        { flag_h, flag_d, flag_i, flag_r } <= 4'b0000;
      else if (!cpu_ADS_n)
        { flag_h, flag_d, flag_i, flag_r } <= cpu_D_o[7:4];
   end

   //debug interface
   assign led_n    = ~ { flag_h, flag_d, flag_i, flag_r, ~ser_rx, ~ser_tx };

   rPLL
     #( // For GW1NR-9C C6/I5 (Tang Nano 9K proto dev board)
        .FCLKIN("27"),
        .IDIV_SEL(8), // -> PFD = 3 MHz (range: 3-400 MHz)
        .FBDIV_SEL(7), // -> CLKOUT = 24 MHz (range: 3.125-600 MHz)
        .DYN_SDIV_SEL(6),
        .ODIV_SEL(32) // -> VCO = 768 MHz (range: 600-1200 MHz)
        )
   pll
     (
      .CLKOUT(),
      .CLKOUTP(),
      .RESET(1'b0),
      .RESET_P(1'b0),
      .CLKFB(1'b0),
      .FBDSEL(6'b0),
      .IDSEL(6'b0),
      .ODSEL(6'b0),
      .PSDA(4'b0),
      .DUTYDA(4'b0),
      .FDLY(4'b0),
      .CLKIN(sys_clk), // 27 MHz
      .CLKOUTD3(ram_clk), // 8 MHz
      .CLKOUTD(cpu_clk),  // 4 MHz
      .LOCK(pll_lock)
      );


   // assign ram_clk = sys_clk;
   // assign pll_lock = 1'b1;

   // CLKDIV
   //   #(
   //     .DIV_MODE(2),
   //     .GSREN("false")
   //     )
   // clkdiv
   //   (
   //    .RESETN(1'b1),
   //    .HCLKIN(sys_clk),
   //    .CLKOUT(cpu_clk),
   //    .CALIB(1'b1)
   //    );

endmodule

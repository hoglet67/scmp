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
    output [5:0] led_n,
    output       phi,
    output [7:0] data
    );


   logic         clk_1m;
   logic         cpu_clk;
   logic         ram_clk;

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

   logic              cpu_sa_i;
   logic              cpu_sb_i;

   logic              cpu_rst_n = 1'b0;
   logic [15:0]       reset_counter = 16'h0000;

   logic              ext_ram_enable;
   logic              ext_ram_wr;
   logic [15:0]       ext_ram_addr;
   logic [7:0]        ext_ram[0:65535];
   logic [7:0]        ext_ram_D_Q;

   initial begin
      $readmemh("8060nibl_2400baud_putcfixed.mi", ext_ram, 'h0000);
      $readmemh("KitBug++.mi",                    ext_ram, 'h2000);
      $readmemh("MON_NIBLFP.mi",                  ext_ram, 'hC000);
   end

   always_comb begin
      ext_ram_enable = 1'b1;      
      ext_ram_wr     = (cpu_addr_latched == 4'h1 || (cpu_addr_latched >= 4'h3 && cpu_addr_latched <= 4'hB));
      ext_ram_addr   = {cpu_addr_latched, cpu_addr};
   end

   always_ff@(posedge ram_clk)
     begin
        ext_ram_D_Q <= ext_ram[ext_ram_addr];
        if (!cpu_WR_n & ext_ram_enable & ext_ram_wr)
          ext_ram[ext_ram_addr] <= cpu_D_o;
     end

   always_comb begin
      if (!cpu_RD_n)
        if (ext_ram_enable)
          cpu_D_i <= ext_ram_D_Q;
        else
          cpu_D_i <= 8'hff;
      else
        cpu_D_i <= 8'bZZZZZZZZ;
   end

   assign ser_tx = !cpu_f0;

   always_ff@(posedge cpu_clk)
     begin
        if (btn1)
          reset_counter <= 16'h0000;
        else if (!reset_counter[15])
          reset_counter <= reset_counter + 1'b1;
        cpu_rst_n <= reset_counter[15];
        cpu_sb_i <= ser_rx;
        cpu_sa_i <= 1'b0;
     end

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

   always@(posedge cpu_clk) begin
      if (!cpu_rst_n)
        { flag_h, flag_d, flag_i, flag_r } <= 4'b0000;
      else if (!cpu_ADS_n)
        { flag_h, flag_d, flag_i, flag_r } <= cpu_D_o[7:4];
   end

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
      .LOCK()
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


   // For instruction tracing
   assign phi   = cpu_clk;
   assign data  = (cpu_ADS_n & cpu_WR_n) ? cpu_D_i : cpu_D_o;

   // led_n[0] =>  D8 = unused (rnw on 6502 so connect cpu_WR_n)
   // led_n[1] =>  D9 = ADS_n
   // led_n[2] => D10 = HOLD
   // led_n[3] => D11 = SA
   // led_n[4] => D12 = SB
   //             D13 = unused
   // led_n[5] => D14 = RST_n
   //             D15 = async clock
   assign led_n = { cpu_rst_n, cpu_sb_i, cpu_sa_i, 1'b0, cpu_ADS_n, cpu_WR_n};

endmodule

`timescale 1 ns / 1 ns
`define MEM_SIZE 128

module lcds
  #(      parameter C_SIZE = 12,
          SIM = 0
          )
   (
    input        sys_clk,
    input        btn1,
    input        ser_rx,
    input        ps2_clk,
    input        ps2_data,
    output       ser_tx,
    input        js_data,
    output       js_clk,
    output reg   js_load_n,
    output [5:0] led_n,
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

   logic              key_enable;
   logic [7:0]        key_data;

   logic              disp_wr;
   logic [7:0]        disp_data;

   logic              tm1638_clk;
   logic              tm1638_stb;
   logic              tm1638_dio;

   logic              mhz1_clken;
   logic [1:0]        mhz1_counter = 2'b00;

   // Joystick / Config Shift Register
   logic [4:0]        joystick1 = 5'b11111;
   logic [4:0]        joystick2 = 5'b11111;
   logic [5:0]        jumper = 6'b11111;
   logic              last_cpu_clk = 1'b0;
   logic [3:0]        sr_counter = 4'b0000;
   logic [15:0]       sr_mirror = 16'h0000;

   // Memory Map
   // 0000-6FFF not used
   // 7000-703F Keyboard/Display
   // 7040-76FF not used
   // 7700-77FF RAM (256b)
   // 7800-79FF ROM 8H (512b)
   // 7800-79FF ROM 8G (512b)
   // 7800-79FF ROM 8F (512b)
   // 7800-79FF ROM 8E (512b)
   // 8000-FFFF not used

   initial begin
      // Until we have debug logic, hack in a JMP to 7809
      ext_ram[0] = 8'h08;
      ext_ram[1] = 8'hC4;
      ext_ram[2] = 8'h08;
      ext_ram[3] = 8'h33;
      ext_ram[4] = 8'hC4;
      ext_ram[5] = 8'h78;
      ext_ram[6] = 8'h37;
      ext_ram[7] = 8'h3F;
      $readmemh("LCDS-8H-d9315a88.mi", ext_ram, 'h7800);
      $readmemh("LCDS-8G-4d8f5f97.mi", ext_ram, 'h7A00);
      $readmemh("LCDS-8F-928b121a.mi", ext_ram, 'h7C00);
      $readmemh("LCDS-8E-eb321eb2.mi", ext_ram, 'h7E00);
   end

   always_comb begin
      ext_ram_enable = 1'b1;
      ext_ram_wr     = (cpu_addr_latched != 4'h7) || ({cpu_addr_latched, cpu_addr[11:8]} == 8'h77);
      ext_ram_addr   = {cpu_addr_latched, cpu_addr};
      key_enable     = {cpu_addr_latched, cpu_addr[11:8]} == 8'h70;
      disp_wr        = !cpu_WR_n & key_enable;
      disp_data      = {1'b1, cpu_D_o[6:0]};
   end

   always_ff@(posedge ram_clk)
     begin
        ext_ram_D_Q <= ext_ram[ext_ram_addr];
        if (!cpu_WR_n & ext_ram_enable & ext_ram_wr)
          ext_ram[ext_ram_addr] <= cpu_D_o;
     end

   always_comb begin
      if (!cpu_RD_n)
        if (key_enable)
          cpu_D_i <= key_data;
        else if (ext_ram_enable)
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

   // Keypad

   keypad keypad
     (
      .clk(sys_clk),
      .reset(~cpu_rst_n),
      .ps2_clk(ps2_clk),
      .ps2_data(ps2_data),
      .col(cpu_addr[4:0]),
      .halt_mode(halt_mode),
      .row(key_data),
      .halt_sw(),
      .init_sw()
      );

   // Display

   always@(posedge cpu_clk) begin
      mhz1_counter <= mhz1_counter + 1'b1;
      mhz1_clken <= &mhz1_counter;
   end

   tm1638 tm1638
     (
      .clk(cpu_clk),
      .clken(mhz1_clken),
      .reset(~cpu_rst_n),
      .wr(disp_wr),
      .mask({2'b00, cpu_addr[5:0]}),
      .data(disp_data),
      .tm1638_clk(tm1638_clk),
      .tm1638_stb(tm1638_stb),
      .tm1638_dio(tm1638_dio)
      );


   // DIP Switches

   always@(posedge sys_clk) begin
      // external 74LV165A clocked on rising edge, so work here on falling edge
      if (!cpu_clk && last_cpu_clk) begin
         js_load_n <= !(sr_counter == 4'b1111);
         if (sr_counter == 4'b0000) begin
            joystick1 <= sr_mirror[12:8];
            joystick2 <= sr_mirror[4:0];
            jumper    <= sr_mirror[7:5] & sr_mirror[15:13];
         end
         sr_mirror  <= {sr_mirror[14:0], js_data};
         sr_counter <= sr_counter + 1'b1;
      end
      last_cpu_clk <= cpu_clk;
    end

   assign halt_mode = jumper[0];
   assign halt_inst = jumper[1];
   assign run_mode  = jumper[2];

   // For instruction tracing
   assign js_clk = cpu_clk;
   assign data   = (cpu_ADS_n & cpu_WR_n) ? cpu_D_i : cpu_D_o;

   // led_n[0] =>  D8 = unused (rnw on 6502 so connect cpu_WR_n)
   // led_n[1] =>  D9 = ADS_n
   // led_n[2] => D10 = HOLD
   // led_n[3] => D11 = SA
   // led_n[4] => D12 = SB
   //             D13 = unused
   // led_n[5] => D14 = RST_n
   //             D15 = async clock

   // assign led_n = { cpu_rst_n, cpu_sb_i, cpu_sa_i, 1'b0, cpu_ADS_n, cpu_WR_n};

   assign led_n = { tm1638_dio, tm1638_clk, tm1638_stb, halt_mode, cpu_ADS_n, cpu_WR_n};

endmodule

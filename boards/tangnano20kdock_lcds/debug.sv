// LCDS Debug logic

`timescale 1 ns / 1 ns

module debug
  (
   input         clk,
   input         RST_n,
   input         ADS_n,
   input         BUSREQ_n,
   input         DEBUG_n,
   // data bus (for H and I flags)
   input [7:0]   data,
   // toggle switches
   input         halt_inst_toggle,
   input         run_mode_toggle,
   // push switches
   input         init_sw, // Active high
   input         halt_sw, // Active high
   // address busses
   input [15:0]  cpu_addr,
   output [15:0] mem_addr,
   // Control outputs
   output        INDBG_n,
   output        BAEN_n
   );

   logic         halt_sw_debounced;
   logic         trig_halt_inst;
   logic         trig_halt_sw;
   logic         trig_halt;
   logic         trig_sync;

   logic         BUSREQ_n_last;
   logic         debug_address_enable = 1'b1;
   logic         in_debug;
   logic [4:0]   debug_counter;
   logic [7:0]   debug_data;
   logic         debug_y7;
   logic         debug_y8;
   logic [15:0]  debug_addr;

   // See page 5-23 of the SC/MP LCDS Users Manual (4200105A)
   logic [7:0]        debug_prom[0:31];

   initial begin
      debug_prom[ 0] = 8'h00;
      debug_prom[ 1] = 8'h30;
      debug_prom[ 2] = 8'h30;
      debug_prom[ 3] = 8'h0D;
      debug_prom[ 4] = 8'h31;
      debug_prom[ 5] = 8'h32;
      debug_prom[ 6] = 8'h33;
      debug_prom[ 7] = 8'h30;
      debug_prom[ 8] = 8'h30;
      debug_prom[ 9] = 8'h0C;
      debug_prom[10] = 8'h31;
      debug_prom[11] = 8'h34;
      debug_prom[12] = 8'h35;
      debug_prom[13] = 8'h30;
      debug_prom[14] = 8'h30;
      debug_prom[15] = 8'h0B;
      debug_prom[16] = 8'h36;
      debug_prom[17] = 8'h30;
      debug_prom[18] = 8'h30;
      debug_prom[19] = 8'h0F;
      debug_prom[20] = 8'h78;
      debug_prom[21] = 8'h38;
      debug_prom[22] = 8'h37;
      debug_prom[23] = 8'h31;
      debug_prom[24] = 8'h0C;
      debug_prom[25] = 8'h33;
      debug_prom[26] = 8'h31;
      debug_prom[27] = 8'h0B;
      debug_prom[28] = 8'h35;
      debug_prom[29] = 8'h31;
      debug_prom[30] = 8'hCD;
      debug_prom[31] = 8'h0B;
   end

   assign debug_data = debug_prom[debug_counter];

   assign debug_y7 = debug_data[6];
   assign debug_y8 = debug_data[7];

   assign debug_addr = { 4'b0111, debug_data[5], {7{!debug_data[4]}}, debug_data[3:0] };

   assign mem_addr = debug_address_enable ? debug_addr : cpu_addr;

   // Halt switch bebouncing (and synchroniziation)
   always@(posedge clk) begin
      if (halt_sw || !run_mode_toggle)
        halt_sw_debounced <= 1'b1;
      else if (debug_address_enable)
        halt_sw_debounced <= 1'b0;
   end

   // DFF 8B - halt switch trigger
   // in debug mode:
   //    ignore the halt switch
   // in run mode:
   //    trigger when halt switch depressed (=0) or when the run mode
   //    toggle switch is set to step (=0).
   //
   // Note: when single stepping, the !ADS_n term introduces
   // delay. Without this, debug mode is re-entered immediately,
   // preventing any forward progress. In the original curcuit the is
   // achived by clocking DFF 8B off the trailing edge of ADS_n.
   always@(posedge clk) begin
      if (!RST_n)
        trig_halt_sw <= 1'b0;
      else if (!ADS_n)
        trig_halt_sw <= !in_debug && (!DEBUG_n || halt_sw_debounced);
   end

   // SR latch 9B - halt instruction trigger
   // in debug mode:
   //    trigger on all halt instruction
   //    (this will be the halt that starts the return sequence)
   // in run mode:
   //    trigger on trigger on halt instructions when the halt inst
   //    toggle switch is in the DEBUG setting (=0)
   always@(posedge clk) begin
      if (!RST_n || debug_address_enable)
        trig_halt_inst <= 1'b0;
      else if (!ADS_n && data[7] && (!halt_inst_toggle || in_debug))
        trig_halt_inst <= 1'b1;
   end

   // The two halt triggers are logically ORed together (6B)
   assign trig_halt = trig_halt_sw || trig_halt_inst;

   // Synchronize the trigger to the next instruction fetch
   assign trig_sync = trig_halt && !ADS_n && data[5];

   // Debug multiplexor control (address jamming)
   always@(posedge clk) begin
      if (!RST_n || trig_sync) begin
         debug_address_enable <= 1'b1;
      end else if (BUSREQ_n && debug_y7) begin
         debug_address_enable <= 1'b0;
      end
   end

   // Debug mode / Run mode state
   always@(posedge clk) begin
      if (!RST_n || trig_sync) begin
         in_debug <= 1'b1;
      end else if (BUSREQ_n && debug_y8) begin
         in_debug <= 1'b0;
      end
   end

   // Debug counter control
   always@(posedge clk) begin
      BUSREQ_n_last <= BUSREQ_n;
      if (!RST_n || (BUSREQ_n && debug_y8)) begin
         // Cleared on the reset and when BUSREQ released
         debug_counter <= 5'b00000;
      end else if (!BUSREQ_n && BUSREQ_n_last && debug_address_enable || trig_sync) begin
         // Incremented on the leading edge of BUSREQ
         debug_counter <= debug_counter + 1'b1;
      end
   end

   // Control output
   assign INDBG_n = !in_debug;
   assign BAEN_n = debug_address_enable;

endmodule

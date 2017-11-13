#include"../../../controller/max_val_gen/max_val_gen.hpp"

#define NUM_SAMPLE_WIDTHS 5
#define COUNTER_WIDTH 9
#define STAGE_WIDTH 4

SC_MODULE(TEST_MAX_GEN){

  sc_core::sc_in_clk clk;
  // Inputs
  sc_core::sc_signal<sc_dt::sc_uint<NUM_SAMPLE_WIDTHS> > sample_width_selector;

  // Outputs
  sc_core::sc_signal<sc_dt::sc_uint<COUNTER_WIDTH> > max_count;
  sc_core::sc_signal<sc_dt::sc_uint<STAGE_WIDTH> > max_stage;


  // DUT
  max_generator<NUM_SAMPLE_WIDTHS, COUNTER_WIDTH, STAGE_WIDTH> dut;

  void do_test(){
    sample_width_selector.write(16);
    wait(2);
    sample_width_selector.write(8);
    wait(2);
    sample_width_selector.write(4);
    wait(2);
    sample_width_selector.write(2);
    wait(2);
    sample_width_selector.write(1);
    wait(2);
    sc_core::sc_stop();
  }

  SC_CTOR(TEST_MAX_GEN) : dut("max_gen"){
    // Binding of signals
    dut.sample_width_selector(sample_width_selector);
    dut.max_count(max_count);
    dut.max_stage(max_stage);
    SC_CTHREAD(do_test, clk.pos());
  }
};

int sc_main(int argc, char* argv[]){
  sc_core::sc_clock clock1("clock1", 20, 0.5, 2, true);
  TEST_MAX_GEN test("test1");
    test.clk(clock1);
  sc_core::sc_trace_file *wf = sc_core::sc_create_vcd_trace_file("max_gen");
  sc_core::sc_trace(wf, test.clk, "clock");
  sc_core::sc_trace(wf, test.max_count, "max_count");
  sc_core::sc_trace(wf, test.max_stage, "max_stage");
  sc_core::sc_trace(wf, test.sample_width_selector, "sample_width_selector");
  sc_core::sc_start();
  sc_core::sc_close_vcd_trace_file(wf);
  return 0;
}

#include"../../../controller/stage_counter/stage_counter.hpp"
#define STAGE_WIDTH 4
SC_MODULE(TEST_STAGE_CNT){
  sc_core::sc_in_clk clk;

  sc_core::sc_signal<bool> reset,
                           enable,
                           stage_finish;

  sc_core::sc_signal<sc_dt::sc_uint<STAGE_WIDTH> > stage_cnt;


  // DUT
  stage_counter<STAGE_WIDTH> dut;

  void do_test(){
    reset.write(true);
    enable.write(true);
    wait(1);
    reset.write(false);
    wait(3);
    stage_finish.write(true);
    wait(1);
    stage_finish.write(false);
    wait(3);
    stage_finish.write(true);
    wait(1);
    stage_finish.write(false);
    wait(5);
    sc_core::sc_stop();
  }

  SC_CTOR(TEST_STAGE_CNT) : dut("stage_cnt"){
    // Binding of signals
    dut.clk(clk);
    dut.reset(reset);
    dut.enable(enable);
    dut.stage_finish(stage_finish);
    dut.stage_cnt(stage_cnt);

    SC_CTHREAD(do_test, clk.pos());
  }
};

int sc_main(int argc, char* argv[]){
  sc_core::sc_clock clock1("clock1", 20, 0.5, 2, true);
  TEST_STAGE_CNT test("test1");
    test.clk(clock1);
  sc_core::sc_trace_file *wf = sc_core::sc_create_vcd_trace_file("stage_cnt");
  sc_core::sc_trace(wf, test.clk, "clock");
  sc_core::sc_trace(wf, test.reset, "reset");
  sc_core::sc_trace(wf, test.enable, "enable");
  sc_core::sc_trace(wf, test.stage_finish, "stage_finish");
  sc_core::sc_trace(wf, test.stage_cnt, "stage_cnt");
  sc_core::sc_start();
  sc_core::sc_close_vcd_trace_file(wf);
  return 0;
}

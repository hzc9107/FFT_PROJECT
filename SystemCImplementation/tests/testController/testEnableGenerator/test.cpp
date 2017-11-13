#include"../../../controller/enable_generator/enable_generator.hpp"

SC_MODULE(TEST_EN_GEN){
  sc_core::sc_in_clk clk;

  sc_core::sc_signal<bool> reset,
                           start,
                           mem_selector,
                           stage_finish,
                           pipe_finish;

  sc_core::sc_signal<bool> addr_gen_en,
                           pipe_en,
                           memA_wen,
                           memB_wen;


  // DUT
  enable_generator dut;

  void do_test(){
    reset.write(true);
    wait(1);
    reset.write(false);
    wait(2);
    start.write(true);
    mem_selector.write(true);
    wait(2);
    stage_finish.write(true);
    wait(1);
    stage_finish.write(false);
    wait(2);
    pipe_finish.write(true);
    wait(1);
    pipe_finish.write(false);
    wait(5);
    sc_core::sc_stop();
  }

  SC_CTOR(TEST_EN_GEN) : dut("en_gen"){
    // Binding of signals
    dut.clk(clk);
    dut.reset(reset);
    dut.start(start);
    dut.mem_selector(mem_selector);
    dut.stage_finish(stage_finish);
    dut.pipe_finish(pipe_finish);
    dut.addr_gen_en(addr_gen_en);
    dut.pipe_en(pipe_en);
    dut.memA_wen(memA_wen);
    dut.memB_wen(memB_wen);

    SC_CTHREAD(do_test, clk.pos());
  }
};

int sc_main(int argc, char* argv[]){
  sc_core::sc_clock clock1("clock1", 20, 0.5, 2, true);
  TEST_EN_GEN test("test1");
    test.clk(clock1);
  sc_core::sc_trace_file *wf = sc_core::sc_create_vcd_trace_file("en_gen");
  sc_core::sc_trace(wf, test.clk, "clock");
  sc_core::sc_trace(wf, test.reset, "reset");
  sc_core::sc_trace(wf, test.start, "start");
  sc_core::sc_trace(wf, test.mem_selector, "selector");
  sc_core::sc_trace(wf, test.stage_finish, "stage_finish");
  sc_core::sc_trace(wf, test.pipe_finish, "pipe_finish");
  sc_core::sc_trace(wf, test.addr_gen_en, "addr_gen_en");
  sc_core::sc_trace(wf, test.pipe_en, "pipe_en");
  sc_core::sc_trace(wf, test.memA_wen, "memA_wen");
  sc_core::sc_trace(wf, test.memB_wen, "memB_wen");
  sc_core::sc_trace(wf, test.dut.internal_state, "state");
  sc_core::sc_start();
  sc_core::sc_close_vcd_trace_file(wf);
  return 0;
}

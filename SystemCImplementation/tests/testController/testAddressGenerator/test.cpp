#include"../../../controller/address_generator/address_generator.hpp"

#define ADDRESS_WIDTH 10
#define COUNTER_WIDTH 9
#define STAGE_WIDTH 9

SC_MODULE(TEST_ADDR_GEN){
  sc_core::sc_in_clk clk;

  sc_core::sc_signal<bool> reset, enable;
  sc_core::sc_signal<sc_dt::sc_uint<COUNTER_WIDTH> > max_count;
  sc_core::sc_signal<sc_dt::sc_uint<STAGE_WIDTH> > stage_count;

  // Outputs
  sc_core::sc_signal<bool> stage_finish;
  sc_core::sc_signal<sc_dt::sc_uint<ADDRESS_WIDTH> > address_low, address_high;


  // DUT
  address_generator<ADDRESS_WIDTH, COUNTER_WIDTH, STAGE_WIDTH> dut;

  void do_test(){
    reset.write(true);
    enable.write(false);
    wait(2);
    reset.write(false);
    max_count.write(511);
    stage_count.write(0);
    wait(2);
    enable.write(true);
    wait(550);
    reset.write(true);
    enable.write(false);
    wait(2);
    stage_count.write(2);
    reset.write(false);
    wait(1);
    enable.write(true);
    wait(550);
    sc_core::sc_stop();
  }

  void monitor(){
    std::cout << address_low << " " << address_high << std::endl;
  }

  SC_CTOR(TEST_ADDR_GEN) : dut("pipe1"){
    // Binding of signals
    dut.clk(clk);
    dut.reset(reset);
    dut.enable(enable);
    dut.max_count(max_count);
    dut.stage_count(stage_count);
    dut.stage_finish(stage_finish);
    dut.address_high(address_high);
    dut.address_low(address_low);

    SC_CTHREAD(do_test, clk.pos());

    SC_METHOD(monitor);
      sensitive << address_high << address_low;
  }
};

int sc_main(int argc, char* argv[]){
  sc_core::sc_clock clock1("clock1", 20, 0.5, 2, true);
  TEST_ADDR_GEN test("test1");
    test.clk(clock1);
  sc_core::sc_trace_file *wf = sc_core::sc_create_vcd_trace_file("pipeline");
  sc_core::sc_trace(wf, test.clk, "clock");
  sc_core::sc_trace(wf, test.reset, "reset");
  sc_core::sc_trace(wf, test.enable, "enable");
  sc_core::sc_trace(wf, test.max_count, "max_count");
  sc_core::sc_trace(wf, test.stage_count, "stage_count");
  sc_core::sc_trace(wf, test.stage_finish, "stage_finish");
  sc_core::sc_trace(wf, test.address_low, "address_low");
  sc_core::sc_trace(wf, test.address_high, "address_high");
  sc_core::sc_start();
  sc_core::sc_close_vcd_trace_file(wf);
  return 0;
}

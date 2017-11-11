#include"../../../controller/twiddle_address_generator/twiddle_address_generator.hpp"

#define ADDRESS_WIDTH 11
#define STAGE_WIDTH 4

SC_MODULE(TEST_ADDR_GEN){
  sc_core::sc_in_clk clk;

  sc_core::sc_signal<bool> reset, enable;
  sc_core::sc_signal<sc_dt::sc_uint<STAGE_WIDTH> > stage_count;
  sc_core::sc_signal<sc_dt::sc_uint<ADDRESS_WIDTH> > sample_number;

  // Outputs
  sc_core::sc_signal<sc_dt::sc_uint<ADDRESS_WIDTH> > twiddle_address;


  // DUT
  twiddle_generator<ADDRESS_WIDTH, STAGE_WIDTH> dut;

  void do_test(){
    reset.write(true);
    enable.write(false);
    wait(2);
    reset.write(false);
    stage_count.write(0);
    sample_number.write(1024);
    wait(2);
    enable.write(true);
    wait(10);
    reset.write(true);
    enable.write(false);
    wait(2);
    reset.write(false);
    stage_count.write(2);
    wait(1);
    enable.write(true);
    wait(20);
    reset.write(true);
    enable.write(false);
    wait(2);
    reset.write(false);
    stage_count.write(7);
    wait(1);
    enable.write(true);
    wait(30);
    sc_core::sc_stop();
  }

  void monitor(){
    std::cout << twiddle_address << std::endl;
  }

  SC_CTOR(TEST_ADDR_GEN) : dut("twiddle_gen1"){
    // Binding of signals
    dut.clk(clk);
    dut.reset(reset);
    dut.enable(enable);
    dut.stage_count(stage_count);
    dut.twiddle_address(twiddle_address);
    dut.sample_number(sample_number);

    SC_CTHREAD(do_test, clk.pos());

    SC_METHOD(monitor);
      sensitive << twiddle_address;
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
  sc_core::sc_trace(wf, test.stage_count, "stage_count");
  sc_core::sc_trace(wf, test.sample_number, "sample_number");
  sc_core::sc_trace(wf, test.twiddle_address, "twiddle_addr");
  sc_core::sc_start();
  sc_core::sc_close_vcd_trace_file(wf);
  return 0;
}

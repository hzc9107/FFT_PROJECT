#include"../../controller/controller.hpp"
#define SAMPLE_WIDTH 11
#define ADDRESS_WIDTH 10
#define STAGE_WIDTH 4
#define NUMBER_OF_SUPPORTED_SAMPLE_SIZE 5

SC_MODULE(TEST_CTRL){
  sc_core::sc_in_clk clk;

  // Inputs
  sc_core::sc_signal<bool> reset,
                           start,
                           pipe_finish;

  sc_core::sc_signal<sc_dt::sc_uint<SAMPLE_WIDTH> > number_of_samples;

  // Outputs
  sc_core::sc_signal<sc_dt::sc_uint<ADDRESS_WIDTH> > address_low,
                                                     twiddle_address,
                                                     address_high;

  sc_core::sc_signal<bool> mem_en,
                           pipe_en,
                           memA_wen,
                           memB_wen,
                           stage_finish;

  // Internal signals
  sc_core::sc_signal<bool> temp_pipe_finish;

  // DUT
  controller<SAMPLE_WIDTH, ADDRESS_WIDTH, STAGE_WIDTH, NUMBER_OF_SUPPORTED_SAMPLE_SIZE> dut;

  void do_test(){
    reset.write(true);
    start.write(false);
    number_of_samples.write(64);
    wait(2);
    reset.write(false);
    start.write(true);
    wait(1000);
    sc_core::sc_stop();
  }

  void assign_pipe_finish(){
    if(reset){
      temp_pipe_finish.write(false);
      pipe_finish.write(false);
    } else {
      pipe_finish.write(temp_pipe_finish.read());
      temp_pipe_finish.write(stage_finish.read());
    }
  }

  void monitor(){
    std::cout << "LOW: " << address_low << "HIGH: " << address_high << "Twid: " <<twiddle_address << std::endl;
  }

  SC_CTOR(TEST_CTRL) : dut("controller1"){
    // Binding of signals
    dut.clk(clk);
    dut.reset(reset);
    dut.start(start);
    dut.pipe_finish(pipe_finish);
    dut.number_of_samples(number_of_samples);
    dut.twiddle_address(twiddle_address);
    dut.address_low(address_low);
    dut.address_high(address_high);
    dut.mem_en(mem_en);
    dut.pipe_en(pipe_en);
    dut.memA_wen(memA_wen);
    dut.memB_wen(memB_wen);
    dut.stage_finish(stage_finish);

    SC_CTHREAD(do_test, clk.pos());

    SC_METHOD(monitor);
      sensitive << twiddle_address << address_low << address_high;

    SC_METHOD(assign_pipe_finish);
      sensitive << clk.pos();
  }
};

int sc_main(int argc, char* argv[]){
  sc_core::sc_clock clock1("clock1", 20, 0.5, 2, true);
  TEST_CTRL test("test1");
    test.clk(clock1);
  sc_core::sc_trace_file *wf = sc_core::sc_create_vcd_trace_file("controller");
  sc_core::sc_trace(wf, test.clk, "clock");
  sc_core::sc_trace(wf, test.reset, "reset");;
  sc_core::sc_trace(wf, test.start, "start");
  sc_core::sc_trace(wf, test.pipe_finish, "pipe_finish");
  sc_core::sc_trace(wf, test.number_of_samples, "number_of_samples");
  sc_core::sc_trace(wf, test.address_low, "address_low");
  sc_core::sc_trace(wf, test.address_high, "address_high");
  sc_core::sc_trace(wf, test.twiddle_address, "twiddle_addr");
  sc_core::sc_trace(wf, test.mem_en, "mem_en");
  sc_core::sc_trace(wf, test.pipe_en, "pipe_en");
  sc_core::sc_trace(wf, test.memA_wen, "memA_wen");
  sc_core::sc_trace(wf, test.memB_wen, "memB_wen");
  sc_core::sc_trace(wf, test.stage_finish, "stage_finish");
  sc_core::sc_start();
  sc_core::sc_close_vcd_trace_file(wf);
  return 0;
}

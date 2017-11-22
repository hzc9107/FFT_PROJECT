#include "../../fft_module.hpp"
#define SAMPLE_WIDTH 11
#define DATA_WIDTH 32
#define ADDRESS_WIDTH 10
#define STAGE_WIDTH 4
#define NUM_SAMPLE_SIZE 5
SC_MODULE(TEST_FFT){
  // Clock input
  sc_core::sc_in_clk clk;

  // Signal Definitions
  sc_core::sc_signal<bool> reset,
                           start,
                           finish;

  sc_core::sc_signal<sc_dt::sc_uint<SAMPLE_WIDTH> > sample_size;

  // DUT
  fft_module<DATA_WIDTH, ADDRESS_WIDTH, SAMPLE_WIDTH, STAGE_WIDTH, NUM_SAMPLE_SIZE> dut;

  void do_test(){
    reset.write(true);
    start.write(false);
    sample_size.write(64);
    wait(2);
    reset.write(false);
    start.write(true);
    wait(2);
    start.write(false);
    wait(800);
    sc_core::sc_stop();
  }

  void monitor(){
    dut.memoryA.write_memory_to_file("memAFinal.txt");
    dut.memoryB.write_memory_to_file("memBFinal.txt");
  }
  SC_CTOR(TEST_FFT) : dut("fft_module") {

    // Connect dut
    dut.clk(clk);
    dut.reset(reset);
    dut.start(start);
    dut.sample_size(sample_size);
    dut.finish(finish);

    dut.read_in_memA_contents("memoryAContents.txt");
    dut.read_in_twid_mem_contents("twidMemContents.txt");

    SC_CTHREAD(do_test, clk.pos());
    SC_METHOD(monitor);
    sensitive << finish;
  }
};

int sc_main(int argc, char *argv[]){
  sc_core::sc_clock clock1("clock1", 20, 0.5, 2, true);
  TEST_FFT test("fft_test");
    test.clk(clock1);
  sc_core::sc_trace_file *wf = sc_core::sc_create_vcd_trace_file("FFT");
  // Signals from the top module
  sc_core::sc_trace(wf, test.clk, "clock");
  sc_core::sc_trace(wf, test.reset, "reset");;
  sc_core::sc_trace(wf, test.start, "start");
  sc_core::sc_trace(wf, test.sample_size, "sample_size");
  sc_core::sc_trace(wf, test.dut.pipe_en, "pipe_en");
  sc_core::sc_trace(wf, test.dut.writeEnable, "pipe_finish_in");
  sc_core::sc_trace(wf, test.dut.firstOperandReal, "op_real_1");
  sc_core::sc_trace(wf, test.dut.firstOperandImaginary, "op_im_1");
  sc_core::sc_trace(wf, test.dut.secondOperandReal, "op_real_2");
  sc_core::sc_trace(wf, test.dut.secondOperandImaginary, "op_im_2");
  sc_core::sc_trace(wf, test.dut.twiddleFactorReal, "twid_real");
  sc_core::sc_trace(wf, test.dut.twiddleFactorImaginary, "twid_im");
  sc_core::sc_trace(wf, test.dut.twiddleAddress, "twid_addr");
  sc_core::sc_trace(wf, test.dut.firstOperandOutReal, "out_real_op_1");
  sc_core::sc_trace(wf, test.dut.firstOperandOutImaginary, "out_im_op_1");
  sc_core::sc_trace(wf, test.dut.secondOperandOutReal, "out_real_op_2");
  sc_core::sc_trace(wf, test.dut.secondOperandOutImaginary, "out_im_op_2");
  sc_core::sc_trace(wf, test.dut.destAddressOutLow, "addr_out_low");
  sc_core::sc_trace(wf, test.dut.destAddressOutHigh, "addr_out_high");
  sc_core::sc_trace(wf, test.dut.writeEnableOut, "pipe_finish_out");
  sc_core::sc_trace(wf, test.dut.memADataAOut, "memA_PA_Out");
  sc_core::sc_trace(wf, test.dut.memADataBOut, "memA_PB_Out");
  sc_core::sc_trace(wf, test.dut.memBDataAOut, "memB_PA_Out");
  sc_core::sc_trace(wf, test.dut.memBDataBOut, "memB_PB_Out");
  sc_core::sc_trace(wf, test.dut.memDataAIn, "memX_PA_In");
  sc_core::sc_trace(wf, test.dut.memDataBIn, "memX_PB_In");
  sc_core::sc_trace(wf, test.dut.twiddle_dataA, "twid_data_A");
  sc_core::sc_trace(wf, test.dut.twiddle_dataB, "twid_data_B");
  sc_core::sc_trace(wf, test.dut.memAAddressA, "memA_Addr_A");
  sc_core::sc_trace(wf, test.dut.memAAddressB, "memA_Addr_B");
  sc_core::sc_trace(wf, test.dut.memBAddressA, "memB_Addr_A");
  sc_core::sc_trace(wf, test.dut.memBAddressB, "memB_Addr_B");
  sc_core::sc_trace(wf, test.dut.memEnable, "mem_en");
  sc_core::sc_trace(wf, test.dut.writeAEn, "writeA_en");
  sc_core::sc_trace(wf, test.dut.writeBEn, "writeBEn");
  sc_core::sc_trace(wf, test.dut.address_low, "addr_in_low");
  sc_core::sc_trace(wf, test.dut.address_high, "addr_in_high");
  sc_core::sc_trace(wf, test.dut.twiddle_address, "twid_addr");
  sc_core::sc_trace(wf, test.finish, "finish");

  //Signals from pipeline_instance
  sc_core::sc_trace(wf, test.dut.pipeline_instance.multStageFirstOperandReal, "mult_real_op1");
  sc_core::sc_trace(wf, test.dut.pipeline_instance.multStageFirstOperandImaginary, "mult_im_op1");
  sc_core::sc_trace(wf, test.dut.pipeline_instance.multStageResultReal, "mult_res_real");
  sc_core::sc_trace(wf, test.dut.pipeline_instance.multStageResultImaginary, "mult_res_im");
  sc_core::sc_trace(wf, test.dut.pipeline_instance.multStageResultImaginaryReal, "mult_res_im_real");
  sc_core::sc_trace(wf, test.dut.pipeline_instance.multStageResultRealImaginary, "mult_res_real_im");


  sc_core::sc_start();
  sc_core::sc_close_vcd_trace_file(wf);
}

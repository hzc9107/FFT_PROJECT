#include<fstream>
#include"../../pipeline/pipeline.h"

#define DATA_WIDTH 16
#define ADDRESS_WIDTH 4

SC_MODULE(TEST_PIPELINE){
  sc_core::sc_in_clk clk;
  sc_core::sc_signal<bool> addStageEnable, multStageEnable, reset, writeEnableIn, writeEnableOut;
  sc_core::sc_signal<sc_dt::sc_int<DATA_WIDTH> > firstOperandReal,
                                             firstOperandImaginary,
                                             secondOperandReal,
                                             secondOperandImaginary,
                                             twiddleFactorReal,
                                             twiddleFactorImaginary;

  sc_core::sc_signal<sc_dt::sc_int<ADDRESS_WIDTH> > destAddressIn;

  sc_core::sc_signal<sc_dt::sc_int<DATA_WIDTH> > firstOperandOutReal,
                                              firstOperandOutImaginary,
                                              secondOperandOutReal,
                                              secondOperandOutImaginary;

  sc_core::sc_signal<sc_dt::sc_int<ADDRESS_WIDTH> > destAddressOut;


  // DUT
  pipeline<DATA_WIDTH, ADDRESS_WIDTH> dut;

  // Test file
  std::ifstream testInputs;
  void do_test(){
    reset.write(true);
    addStageEnable.write(true);
    multStageEnable.write(true);
    writeEnableIn.write(true);
    destAddressIn.write(0);
    wait(5);
    reset.write(false);
    while(!testInputs.eof()){
      int ar, ai, br, bi, wr, wi, aor, aoi, bor, boi;
      testInputs >>  ar >> ai >> br >> bi >> wr >> wi >> aor >> aoi >> bor >> boi;
      firstOperandReal.write(ar);
      firstOperandImaginary.write(ai);
      secondOperandReal.write(br);
      secondOperandImaginary.write(bi);
      twiddleFactorReal.write(wr);
      twiddleFactorImaginary.write(wi);
      wait(1);
    }
    sc_core::sc_stop();

  }

  void monitor(){
    std::cout << "First Stage" << std::endl << "\t" << firstOperandReal.read() << " " << firstOperandImaginary.read() << " " << secondOperandReal.read() << " " << secondOperandImaginary.read() << " " << twiddleFactorReal.read() << " " << twiddleFactorImaginary.read() << std::endl;

    std::cout << "Final Stage" << std::endl << "\t" << firstOperandOutReal.read() << " " << firstOperandOutImaginary.read() << " " << secondOperandOutReal.read() << " " << secondOperandOutImaginary.read() << std::endl;
  }

  SC_CTOR(TEST_PIPELINE) : dut("pipe1"), testInputs("testFIle.ssv"){
    // Binding of signals
    dut.clk(clk);
    dut.addStageEnable(addStageEnable);
    dut.multStageEnable(multStageEnable);
    dut.firstOperandReal(firstOperandReal);
    dut.firstOperandImaginary(firstOperandImaginary);
    dut.secondOperandReal(secondOperandReal);
    dut.secondOperandImaginary(secondOperandImaginary);
    dut.twiddleFactorReal(twiddleFactorReal);
    dut.twiddleFactorImaginary(twiddleFactorImaginary);
    dut.destAddressIn(destAddressIn);
    dut.firstOperandOutReal(firstOperandOutReal);
    dut.firstOperandOutImaginary(firstOperandOutImaginary);
    dut.secondOperandOutReal(secondOperandOutReal);
    dut.secondOperandOutImaginary(secondOperandOutImaginary);
    dut.destAddressOut(destAddressOut);
    dut.reset(reset);
    dut.writeEnable(writeEnableIn);
    dut.writeEnableOut(writeEnableOut);

    SC_CTHREAD(do_test, clk.pos());

    SC_METHOD(monitor);
      sensitive << firstOperandOutReal << firstOperandOutImaginary << secondOperandOutReal << secondOperandOutImaginary;
  }
};

int sc_main(int argc, char* argv[]){
  sc_core::sc_clock clock1("clock1", 20, 0.5, 2, true);
  TEST_PIPELINE test("test1");
    test.clk(clock1);
  sc_core::sc_trace_file *wf = sc_core::sc_create_vcd_trace_file("pipeline");
  sc_core::sc_trace(wf, test.clk, "clock");
  sc_core::sc_trace(wf, test.addStageEnable, "addStageEn");
  sc_core::sc_trace(wf, test.multStageEnable, "multStageEnable");
  sc_core::sc_trace(wf, test.reset, "reset");
  sc_core::sc_trace(wf, test.writeEnableIn, "writeEnIn");
  sc_core::sc_trace(wf, test.firstOperandReal, "Ar");
  sc_core::sc_trace(wf, test.firstOperandImaginary, "Ai");
  sc_core::sc_trace(wf, test.secondOperandReal, "Br");
  sc_core::sc_trace(wf, test.secondOperandImaginary, "Bi");
  sc_core::sc_trace(wf, test.twiddleFactorReal, "Wr");
  sc_core::sc_trace(wf, test.twiddleFactorImaginary, "Wi");
  sc_core::sc_trace(wf, test.destAddressIn, "destAddrIn");
  sc_core::sc_trace(wf, test.firstOperandOutReal, "Aor");
  sc_core::sc_trace(wf, test.firstOperandOutImaginary, "Aoi");
  sc_core::sc_trace(wf, test.secondOperandOutReal, "Bor");
  sc_core::sc_trace(wf, test.secondOperandOutImaginary, "Boi");
  sc_core::sc_trace(wf, test.destAddressOut, "destAddrOut");
  sc_core::sc_trace(wf, test.writeEnableOut, "writeEnOut");
  sc_core::sc_trace(wf, test.dut.multStageFirstOperandReal, "multAr");
  sc_core::sc_trace(wf, test.dut.multStageFirstOperandImaginary, "multAi");
  sc_core::sc_trace(wf, test.dut.multStageResultReal, "ArBr");
  sc_core::sc_trace(wf, test.dut.multStageResultImaginary, "AiBi");
  sc_core::sc_trace(wf, test.dut.multStageResultImaginaryReal,"AiBr");
  sc_core::sc_trace(wf, test.dut.multStageResultRealImaginary, "ArBi");
  sc_core::sc_start();
  sc_core::sc_close_vcd_trace_file(wf);
  return 0;
}

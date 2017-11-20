#include"dual_port_memory.h"

SC_MODULE(TEST_BENCH){
  sc_core::sc_in_clk clk;

  static const unsigned int dataWidth = 32, addressWidth = 3;
  sc_core::sc_signal<sc_dt::sc_uint<dataWidth> > dataA, dataB, dataAOut, dataBOut;
  sc_core::sc_signal<sc_dt::sc_uint<addressWidth> > dataAddrA, dataAddrB;
  sc_core::sc_signal<bool> writeAEn, writeBEn, memEnable; 

  dual_port_memory<dataWidth, addressWidth>  dut;
  
  void do_test() {
    while(true) {
      wait();
      std::cout << "@" << sc_core::sc_time_stamp << "Starting test" << std::endl;
      wait(2);
      memEnable.write(true);
      wait(2);
      dataAddrA.write(12);
      dataAddrB.write(12);
      wait(2);
      dataA.write(12);
      writeAEn.write(true);
      wait(2);
      dataAddrA.write(14);
      dataB.write(13);
      writeBEn.write(true);
      wait(4);
      sc_core::sc_stop();
    }
  }

  SC_CTOR(TEST_BENCH) : dut("mem1"){
    dut.clk(clk);
    dut.dataA(dataA);
    dut.dataB(dataB);
    dut.addressA(dataAddrA);
    dut.addressB(dataAddrB);
    dut.writeAEn(writeAEn);
    dut.writeBEn(writeBEn);
    dut.memEnable(memEnable);
    dut.dataAOut(dataAOut);
    dut.dataBOut(dataBOut);

    SC_CTHREAD(do_test, clk.pos());
  } 
};

int sc_main(int argc, char* argv[]){
  sc_core::sc_clock clock1("clock1", 20, 0.5, 2, true);
  TEST_BENCH test("test1");
    test.clk(clock1);
    sc_core::sc_trace_file *wf = sc_core::sc_create_vcd_trace_file("memory");
    sc_core::sc_trace(wf, test.clk, "clock");
    sc_core::sc_trace(wf, test.dataAddrA, "addrA");
    sc_core::sc_trace(wf, test.dataAddrB, "addrB");
    sc_core::sc_trace(wf, test.dataA, "dataA");
    sc_core::sc_trace(wf, test.dataB, "dataB");
    sc_core::sc_trace(wf, test.writeAEn, "writeEnA");
    sc_core::sc_trace(wf, test.writeBEn, "writeEnB");
    sc_core::sc_trace(wf, test.memEnable, "memEnable");
    sc_core::sc_trace(wf, test.dataAOut, "dataAOut");
    sc_core::sc_trace(wf, test.dataBOut, "dataBOut");
    sc_core::sc_start();
    sc_core::sc_close_vcd_trace_file(wf);
    return 0;
}

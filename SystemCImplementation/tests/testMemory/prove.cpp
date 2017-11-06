#include<systemc>
SC_MODULE(multiplication){
  // Input
  sc_core::sc_in<sc_dt::sc_int<5> > factor1, factor2;

  // Output
  sc_core::sc_out<sc_dt::sc_int<10> > result;

  // Process
  void multiply();

  SC_CTOR(multiplication){
    SC_METHOD(multiply);
      sensitive << factor1 << factor2;
  }

};

void multiplication::multiply(){
  result.write(factor1.read() * factor2.read());
}

SC_MODULE(TEST_MULTIPLICATION){
  sc_core::sc_signal<sc_dt::sc_int<5> > factor1, factor2;
  sc_core::sc_signal<sc_dt::sc_int<10> > result;
  sc_core::sc_in_clk clk;
  multiplication dut;

  void do_test(){
    wait(2);
    factor1.write(10);
    factor2.write(10);
    wait(2);
    factor1.write(15);
    wait(2);
    factor1.write(1 << 4);
    wait(2);  
    factor2.write(1 << 4);
    wait(2);
    factor1.write(0);
    wait(2);
    factor1.write(4);
    wait(2);
    sc_core::sc_stop();
  }

  void monitor(){
    std::cout << factor1.read() << " " << factor2.read() << " " << result.read() << " " << result.read().range(9, 5) << std::endl;
  }

  SC_CTOR(TEST_MULTIPLICATION) : dut("mul1"){
    // DUT binding
    dut.factor1(factor1);
    dut.factor2(factor2);
    dut.result(result);
    
    SC_CTHREAD(do_test, clk.pos());

    SC_METHOD(monitor);
      sensitive << factor1 << factor2;
  }
};

int sc_main(int argc, char* argv[]){
  sc_core::sc_clock clock1("clock1", 20, 0.5, 2, true);
  TEST_MULTIPLICATION tb("test1");
    tb.clk(clock1);
  sc_core::sc_start();
  return 0;
}

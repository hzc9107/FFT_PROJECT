#include<systemc>
template<unsigned int data_width, unsigned int address_width>
SC_MODULE(pipeline){
  // Inputs
  sc_core::sc_clk_in clk;
  sc_core::sc_in<bool> addStageEnable, multStageEnable;
  sc_core::sc_in<sc_dt::sc_int<data_width> > firstOperandReal,
                                             firstOperandImaginary,
                                             secondOperandReal,
                                             secondOperandImaginary,
                                             twiddleFactorReal,
                                             twiddleFactorImaginary;

  sc_core::sc_in<sc_dt::sc_bv<address_width> > destAddressIn;

  // Outputs
  sc_core::sc_out<sc_dt::sc_int<data_width> > firstOperandOutReal,
                                              firstOperandOutImaginary,
                                              secondOperandOutReal,
                                              secondOperandOutImaginary;

  sc_core::sc_out<sc_dt::sc_bv<address_width> > destAddressOut;

  // Internal Variables
  sc_dt::sc_int<data_width> multStageFirstOperandReal,
                            multStageFirstOperandImaginary,
                            multStageResultReal,
                            multStageResultImaginary,
                            multStageResultImaginaryReal,
                            multStageResultRealImaginary;

  sc_dt::sc_bv<address_width> multStageDestAddress;

  // Process
  void pipeline_exec();

  SC_CTOR(pipeline){
    SC_METHOD(pipeline_exec);
      sensitive << clk.pos();
  }

};

template<unsigned int data_width, unsigned int address_width>
void pipeline<data_width, address_width>::pipeline_exec(){
  for(int i = 0; i < 2; ++i){
    if(i == 0 && addStageEnable){
      sc_dt::sc_int<data_width> tempSubstract, tempAdd;
      tempSubstract =
                  multStageResultReal - multStageResultImaginary;
      tempAdd =
                  multStageResultImaginaryReal + multStageResultImaginaryReal;

      firstOperandOutReal.write(
                  multStageFirstOperandReal + tempSubstract);

      firstOperandOutImaginary.write(
                  multStageResultImaginary + tempAdd);

      secondOperandOutReal.write(
                  multStageFirstOperandImaginary - tempSubstract);

      secondOperandOutImaginary.write(
                  multStageFirstOperandImaginary - tempAdd);

      destAddressOut = multStageDestAddress;
    } else if(multStageEnable){
      multStageFirstOperandReal = firstOperandReal.read();

      multStageFirstOperandImaginary = firstOperandImaginary.read();

      multStageResultReal =
        (secondOperandReal.read() * twiddleFactorReal.read()).range(2*address_width-1, address_width);

      multStageResultImaginary =
        (secondOperandImaginary.read() * twiddleFactorImaginary.read()).range(2*address_width-1, address_width);

      multStageResultImaginaryReal =
        (secondOperandImaginary.read() * twiddleFactorReal.read()).range(2*address_width-1, address_width);

      multStageResultRealImaginary = (secondOperandReal.read() * twiddleFactorImaginary.read());

      multStageDestAddress = destAddressIn;
    }
  }
}

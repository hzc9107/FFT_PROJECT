#include<systemc>
#ifndef PIPELINE_H
#define PIPELINE_H

template<unsigned int data_width, unsigned int address_width>
SC_MODULE(pipeline){
  // Inputs
  sc_core::sc_in_clk clk;
  sc_core::sc_in<bool> addStageEnable, multStageEnable, reset, writeEnable;
  sc_core::sc_in<sc_dt::sc_int<data_width> > firstOperandReal,
                                             firstOperandImaginary,
                                             secondOperandReal,
                                             secondOperandImaginary,
                                             twiddleFactorReal,
                                             twiddleFactorImaginary;

  sc_core::sc_in<sc_dt::sc_int<address_width> > destAddressIn;

  // Outputs
  sc_core::sc_out<sc_dt::sc_int<data_width> > firstOperandOutReal,
                                              firstOperandOutImaginary,
                                              secondOperandOutReal,
                                              secondOperandOutImaginary;

  sc_core::sc_out<sc_dt::sc_int<address_width> > destAddressOut;

  sc_core::sc_out<bool> writeEnableOut;

  // Internal Variables
  sc_dt::sc_int<data_width> multStageFirstOperandReal,
                            multStageFirstOperandImaginary,
                            multStageResultReal,
                            multStageResultImaginary,
                            multStageResultImaginaryReal,
                            multStageResultRealImaginary;

  sc_dt::sc_int<address_width> multStageDestAddress;

  bool multStageWriteEnable;
  // Process
  void pipeline_exec();

  SC_CTOR(pipeline){
    SC_METHOD(pipeline_exec);
      sensitive << clk.pos();
  }

};

template<unsigned int data_width, unsigned int address_width>
void pipeline<data_width, address_width>::pipeline_exec(){
  if(reset){
    // Multiplication Stage Signals
    multStageFirstOperandReal = 0;
    multStageFirstOperandImaginary = 0;
    multStageResultReal = 0;
    multStageResultImaginary = 0;
    multStageResultImaginaryReal = 0;
    multStageResultRealImaginary = 0;
    multStageWriteEnable = false;
    multStageDestAddress = 0;

    //Outputs
    firstOperandOutReal.write(0);
    firstOperandOutImaginary.write(0);
    secondOperandOutReal.write(0);
    secondOperandOutImaginary.write(0);
    destAddressOut.write(0);
    destAddressOut.write(0);
    writeEnableOut.write(false);
  } else {
    for(int i = 0; i < 2; ++i){
      if(i == 0 && addStageEnable){
        sc_dt::sc_int<data_width> tempSubstract, tempAdd;
        tempSubstract =
                    multStageResultReal - multStageResultImaginary;
        tempAdd =
                    multStageResultImaginaryReal + multStageResultRealImaginary;

        firstOperandOutReal.write(
                    multStageFirstOperandReal + tempSubstract);

        firstOperandOutImaginary.write(
                    multStageFirstOperandImaginary + tempAdd);

        secondOperandOutReal.write(
                    multStageFirstOperandReal - tempSubstract);

        secondOperandOutImaginary.write(
                    multStageFirstOperandImaginary - tempAdd);


        destAddressOut.write(multStageDestAddress);

        writeEnableOut.write(multStageWriteEnable);
      } else if(multStageEnable){
        multStageFirstOperandReal = firstOperandReal.read();

        multStageFirstOperandImaginary = firstOperandImaginary.read();

        multStageResultReal =
          (secondOperandReal.read() * twiddleFactorReal.read()) >> data_width;

        multStageResultImaginary =
          (secondOperandImaginary.read() * twiddleFactorImaginary.read()) >> data_width;

        multStageResultImaginaryReal =
          (secondOperandImaginary.read() * twiddleFactorReal.read()) >> data_width;

        multStageResultRealImaginary = (secondOperandReal.read() * twiddleFactorImaginary.read()) >> data_width;

        multStageDestAddress = destAddressIn;

        multStageWriteEnable = writeEnable.read();
      }
    }
  }

}

#endif

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

  sc_core::sc_in<sc_dt::sc_uint<address_width> >  destAddressInLow,
                                                  destAddressInHigh;

  // Outputs
  sc_core::sc_out<sc_dt::sc_int<data_width> > firstOperandOutReal,
                                              firstOperandOutImaginary,
                                              secondOperandOutReal,
                                              secondOperandOutImaginary;

  sc_core::sc_out<sc_dt::sc_uint<address_width> > destAddressOutLow,
                                                  destAddressOutHigh;

  sc_core::sc_out<bool> writeEnableOut;

  // Internal Variables
  sc_dt::sc_int<data_width> multStageFirstOperandReal,
                            multStageFirstOperandImaginary,
                            multStageResultReal,
                            multStageResultImaginary,
                            multStageResultImaginaryReal,
                            multStageResultRealImaginary;

  sc_dt::sc_uint<address_width> multStageDestAddressLow,
                                multStageDestAddressHigh,
                                buffStageDestAddressLow,
                                buffStageDestAddressHigh;

  bool multStageWriteEnable, buffStageWriteEnable;
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
    multStageDestAddressHigh = 0;
    multStageDestAddressLow = 0;
    //Outputs
    firstOperandOutReal.write(0);
    firstOperandOutImaginary.write(0);
    secondOperandOutReal.write(0);
    secondOperandOutImaginary.write(0);
    destAddressOutLow.write(0);
    destAddressOutHigh.write(0);
    writeEnableOut.write(false);
  } else {
    for(int i = 0; i < 3; ++i){
      if(i == 0 && addStageEnable){
        sc_dt::sc_int<data_width> tempSubstract, tempAdd;
        if((multStageResultImaginaryReal == 0 && multStageResultRealImaginary == 1) || (multStageResultRealImaginary == 0 && multStageResultImaginaryReal == 1)){
          tempSubstract = multStageResultReal;
          tempAdd       = multStageResultImaginary;
        } else{
          tempSubstract =
                      multStageResultReal - multStageResultImaginary;
          tempAdd =
                      multStageResultImaginaryReal + multStageResultRealImaginary;
        }

        firstOperandOutReal.write(
                    multStageFirstOperandReal + tempSubstract);

        firstOperandOutImaginary.write(
                    multStageFirstOperandImaginary + tempAdd);

        secondOperandOutReal.write(
                    multStageFirstOperandReal - tempSubstract);

        secondOperandOutImaginary.write(
                    multStageFirstOperandImaginary - tempAdd);


        destAddressOutLow.write(multStageDestAddressLow);
        destAddressOutHigh.write(multStageDestAddressHigh);

        writeEnableOut.write(multStageWriteEnable);
      } else if(multStageEnable && i == 1){
        multStageFirstOperandReal = firstOperandReal.read();

        multStageFirstOperandImaginary = firstOperandImaginary.read();

        multStageDestAddressLow = buffStageDestAddressLow;
        multStageDestAddressHigh = buffStageDestAddressHigh;

        multStageWriteEnable = buffStageWriteEnable;

        if(twiddleFactorReal.read() != 0 && twiddleFactorImaginary.read() != 0){
          multStageResultReal =
            (secondOperandReal.read() * twiddleFactorReal.read()) >> (data_width-1);

          multStageResultImaginary =
            (secondOperandImaginary.read() * twiddleFactorImaginary.read()) >> (data_width-1);

          multStageResultImaginaryReal =
            (secondOperandImaginary.read() * twiddleFactorReal.read()) >> (data_width-1);

          multStageResultRealImaginary = (secondOperandReal.read() * twiddleFactorImaginary.read()) >> (data_width-1);

        } else if(twiddleFactorReal.read() == 0){

          multStageResultReal      = secondOperandImaginary.read();
          multStageResultImaginary = secondOperandReal.read();
          multStageResultRealImaginary = 0;
          multStageResultImaginaryReal = 1;

        } else{

          multStageResultReal      = secondOperandReal.read();
          multStageResultImaginary = secondOperandImaginary.read();
          multStageResultRealImaginary = 1;
          multStageResultImaginaryReal = 0;

        }
      } else if(i == 2){
        buffStageWriteEnable = writeEnable.read();
        buffStageDestAddressLow = destAddressInLow.read();
        buffStageDestAddressHigh = destAddressInHigh.read();
      }
    }
  }

}

#endif

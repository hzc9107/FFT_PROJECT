#include<systemc>
#include"controller/controller.hpp"
#include"dual_port_memory/dual_port_memory.h"
#include"pipeline/pipeline.h"

#ifndef FFT_MOD_H
#define FFT_MOD_H

template< unsigned int data_width, unsigned int address_width, unsigned int sample_width, unsigned int stage_width, unsigned int number_of_supported_sample_size>
SC_MODULE(fft_module){
  // Inputs
  sc_core::sc_in_clk clk;
  sc_core::sc_in<bool> reset,
                       start;
  sc_core::sc_in<sc_dt::sc_uint<sample_width> > sample_size;

  // Outputs
  sc_core::sc_out<bool> finish;
  // Signals
  sc_core::sc_signal<bool>  pipe_en,
                            writeEnable;

  sc_core::sc_signal<sc_dt::sc_int<data_width/2> >  firstOperandReal,
                                                  firstOperandImaginary,
                                                  secondOperandReal,
                                                  secondOperandImaginary,
                                                  twiddleFactorReal,
                                                  twiddleFactorImaginary;

  sc_core::sc_signal<sc_dt::sc_int<data_width/2> > firstOperandOutReal,
                                                 firstOperandOutImaginary,
                                                 secondOperandOutReal,
                                                 secondOperandOutImaginary;

  sc_core::sc_signal<sc_dt::sc_uint<address_width> > destAddressOutLow,
                                                     destAddressOutHigh;

  sc_core::sc_signal<bool> writeEnableOut;
  // TODO: Change writeEnable and writeEnableOut to stage_finish and pipeline_finish signal
  sc_core::sc_signal<sc_dt::sc_int<data_width> > memADataAOut,
                                                  memADataBOut,
                                                  memBDataAOut,
                                                  memBDataBOut,
                                                  memDataAIn,
                                                  memDataBIn,
                                                  twiddle_dataA,
                                                  twiddle_dataB;

  sc_core::sc_signal<sc_dt::sc_uint<address_width> >  memAAddressA,
                                                      memAAddressB,
                                                      memBAddressA,
                                                      memBAddressB;

  sc_core::sc_signal<bool>  memEnable,
                            writeAEn,
                            writeBEn;

  sc_core::sc_signal<sc_dt::sc_uint<address_width> >  address_low,
                                                      address_high,
                                                      twiddle_address;

  sc_core::sc_signal<sc_dt::sc_int<data_width> > ceroTiedSignal;
  sc_core::sc_signal<bool> groundSignal;

  // Instances
  controller<sample_width, address_width, stage_width, number_of_supported_sample_size> control_unit;

  dual_port_memory<data_width, address_width> memoryA,
                                              memoryB;

  dual_port_memory<data_width, address_width> twiddle_memory;

  pipeline<data_width/2, address_width> pipeline_instance;

  // Processes
  void assign_memAddrA();
  void assign_memAddrB();
  void assign_memData();
  void tie_sig_to_zero();
  void assign_pipeline_inputs();
  void read_in_memA_contents(std::string memFileName);
  void read_in_twid_mem_contents(std::string memFileName);

  SC_CTOR(fft_module) : memoryA("memA"), memoryB("memB"), twiddle_memory("twid_mem"), control_unit("ctrl_unit"), pipeline_instance("pipe1"){
    // Memory A instantiation
    memoryA.clk(clk);
    memoryA.addressA(memAAddressA);
    memoryA.addressB(memAAddressB);
    memoryA.dataA(memDataAIn);
    memoryA.dataB(memDataBIn);
    memoryA.memEnable(memEnable);
    memoryA.writeAEn(writeAEn);
    memoryA.writeBEn(writeAEn);
    memoryA.dataAOut(memADataAOut);
    memoryA.dataBOut(memADataBOut);

    // Memory B Instantiation
    memoryB.clk(clk);
    memoryB.addressA(memBAddressA);
    memoryB.addressB(memBAddressB);
    memoryB.dataA(memDataAIn);
    memoryB.dataB(memDataBIn);
    memoryB.memEnable(memEnable);
    memoryB.writeAEn(writeBEn);
    memoryB.writeBEn(writeBEn);
    memoryB.dataAOut(memBDataAOut);
    memoryB.dataBOut(memBDataBOut);

    // Twiddle Memory
    twiddle_memory.clk(clk);
    twiddle_memory.addressA(twiddle_address);
    twiddle_memory.addressB(twiddle_address);
    twiddle_memory.dataA(ceroTiedSignal);
    twiddle_memory.dataB(ceroTiedSignal);
    twiddle_memory.writeAEn(groundSignal);
    twiddle_memory.writeBEn(groundSignal);
    twiddle_memory.dataAOut(twiddle_dataA);
    twiddle_memory.dataBOut(twiddle_dataB);
    twiddle_memory.memEnable(memEnable);

    // Controller Instantiation
    control_unit.clk(clk);
    control_unit.reset(reset);
    control_unit.start(start);
    control_unit.pipe_finish(writeEnableOut);
    control_unit.number_of_samples(sample_size);
    control_unit.address_low(address_low);
    control_unit.address_high(address_high);
    control_unit.twiddle_address(twiddle_address);
    control_unit.mem_en(memEnable);
    control_unit.pipe_en(pipe_en);
    control_unit.memA_wen(writeAEn);
    control_unit.memB_wen(writeBEn);
    control_unit.stage_finish(writeEnable);
    control_unit.fft_done(finish);

    // Pipeline Instantiation
    pipeline_instance.clk(clk);
    pipeline_instance.addStageEnable(pipe_en);
    pipeline_instance.multStageEnable(pipe_en);
    pipeline_instance.reset(reset);
    pipeline_instance.writeEnable(writeEnable);
    pipeline_instance.firstOperandReal(firstOperandReal);
    pipeline_instance.firstOperandImaginary(firstOperandImaginary);
    pipeline_instance.secondOperandReal(secondOperandReal);
    pipeline_instance.secondOperandImaginary(secondOperandImaginary);
    pipeline_instance.twiddleFactorReal(twiddleFactorReal);
    pipeline_instance.twiddleFactorImaginary(twiddleFactorImaginary);
    pipeline_instance.firstOperandOutReal(firstOperandOutReal);
    pipeline_instance.firstOperandOutImaginary(firstOperandOutImaginary);
    pipeline_instance.secondOperandOutReal(secondOperandOutReal);
    pipeline_instance.secondOperandOutImaginary(secondOperandOutImaginary);
    pipeline_instance.destAddressInLow(address_low);
    pipeline_instance.destAddressInHigh(address_high);
    pipeline_instance.destAddressOutLow(destAddressOutLow);
    pipeline_instance.destAddressOutHigh(destAddressOutHigh);
    pipeline_instance.writeEnableOut(writeEnableOut);

    SC_METHOD(assign_memAddrA);
      sensitive << address_low << writeAEn << destAddressOutLow;

    SC_METHOD(assign_memAddrB);
      sensitive << address_high << writeAEn << destAddressOutHigh;

    SC_METHOD(assign_memData);
      sensitive << firstOperandOutReal << firstOperandOutImaginary << secondOperandOutReal << secondOperandOutImaginary;

    SC_METHOD(tie_sig_to_zero);
      sensitive << reset;

    SC_METHOD(assign_pipeline_inputs);
      sensitive << memADataAOut << memADataBOut << memBDataAOut << memBDataBOut << writeAEn << twiddle_dataA;
  }
};

template< unsigned int data_width, unsigned int address_width, unsigned int sample_width, unsigned int stage_width, unsigned int number_of_supported_sample_size>
void fft_module<data_width, address_width, sample_width, stage_width, number_of_supported_sample_size>::assign_memAddrA(){
  if(writeAEn.read()){
    memAAddressA.write(destAddressOutLow.read());
    memBAddressA.write(address_low.read());
  } else {
    memAAddressA.write(address_low.read());
    memBAddressA.write(destAddressOutLow.read());
  }
}

template< unsigned int data_width, unsigned int address_width, unsigned int sample_width, unsigned int stage_width, unsigned int number_of_supported_sample_size>
void fft_module<data_width, address_width, sample_width, stage_width, number_of_supported_sample_size>::assign_memAddrB(){
  if(writeAEn.read()){
    memAAddressB.write(destAddressOutHigh.read());
    memBAddressB.write(address_high.read());
  } else {
    memAAddressB.write(address_high.read());
    memBAddressB.write(destAddressOutHigh.read());
  }
}

template< unsigned int data_width, unsigned int address_width, unsigned int sample_width, unsigned int stage_width, unsigned int number_of_supported_sample_size>
void fft_module<data_width, address_width, sample_width, stage_width, number_of_supported_sample_size>::assign_memData(){
  sc_dt::sc_int<data_width> tempDataA, tempDataB;
  tempDataA = (firstOperandOutReal.read(), firstOperandOutImaginary.read());
  tempDataB = (secondOperandOutReal.read(), secondOperandOutImaginary.read());
  memDataAIn.write(tempDataA);
  memDataBIn.write(tempDataB);
}

template< unsigned int data_width, unsigned int address_width, unsigned int sample_width, unsigned int stage_width, unsigned int number_of_supported_sample_size>
void fft_module<data_width, address_width, sample_width, stage_width, number_of_supported_sample_size>::tie_sig_to_zero(){
  ceroTiedSignal.write(0);
  groundSignal.write(false);
}

template< unsigned int data_width, unsigned int address_width, unsigned int sample_width, unsigned int stage_width, unsigned int number_of_supported_sample_size>
void fft_module<data_width, address_width, sample_width, stage_width, number_of_supported_sample_size>::assign_pipeline_inputs(){
  sc_dt::sc_int<data_width/2> tempFirstReal, tempFirstImaginary, tempSecondReal, tempSecondImaginary, tempTwiddleReal, tempTwiddleImaginary;
  if(writeAEn.read()){
    tempFirstReal       = memBDataAOut.read().range(data_width-1, data_width/2);
    tempFirstImaginary  = memBDataAOut.read().range(data_width/2-1,0);
    tempSecondReal      = memBDataBOut.read().range(data_width-1, data_width/2);
    tempSecondImaginary = memBDataBOut.read().range(data_width/2-1,0);
  } else {
    tempFirstReal       = memADataAOut.read().range(data_width-1, data_width/2);
    tempFirstImaginary  = memADataAOut.read().range(data_width/2-1,0);
    tempSecondReal      = memADataBOut.read().range(data_width-1, data_width/2);
    tempSecondImaginary = memADataBOut.read().range(data_width/2-1,0);
  }
  tempTwiddleReal      = twiddle_dataA.read().range(data_width-1, data_width/2);
  tempTwiddleImaginary = twiddle_dataA.read().range(data_width/2-1,0);

  firstOperandReal.write(tempFirstReal);
  firstOperandImaginary.write(tempFirstImaginary);
  secondOperandReal.write(tempSecondReal);
  secondOperandImaginary.write(tempSecondImaginary);
  twiddleFactorReal.write(tempTwiddleReal);
  twiddleFactorImaginary.write(tempTwiddleImaginary);
}

template< unsigned int data_width, unsigned int address_width, unsigned int sample_width, unsigned int stage_width, unsigned int number_of_supported_sample_size>
void fft_module<data_width, address_width, sample_width, stage_width, number_of_supported_sample_size>::read_in_memA_contents(std::string memFileName){
  memoryA.read_vector_from_file(memFileName);
}

template< unsigned int data_width, unsigned int address_width, unsigned int sample_width, unsigned int stage_width, unsigned int number_of_supported_sample_size>
void fft_module<data_width, address_width, sample_width, stage_width, number_of_supported_sample_size>::read_in_twid_mem_contents(std::string memFileName){
  twiddle_memory.read_vector_from_file(memFileName);
}

#endif


#include<systemc>
#include"address_generator/address_generator.hpp"
#include"enable_generator/enable_generator.hpp"
#include"max_val_gen/max_val_gen.hpp"
#include"stage_counter/stage_counter.hpp"
#include"twiddle_address_generator/twiddle_address_generator.hpp"

#ifndef CONTROLLER_H
#define CONTROLLER_H

#define SAMPLE_WIDTH 11
#define ADDRESS_WIDTH 10
#define STAGE_WIDTH 4
#define NUMBER_OF_SUPPORTED_SAMPLE_SIZE 5

SC_MODULE(controller){
  // Inputs
  sc_core::sc_in_clk clk;

  sc_core::sc_in<bool> reset,
                       start,
                       pipe_finish;

  sc_core::sc_in<sc_dt::sc_uint<SAMPLE_WIDTH> > number_of_samples;

  // Outputs
  sc_core::sc_out<sc_dt::sc_uint<ADDRESS_WIDTH> > address_low,
                                                  address_high,
                                                  twiddle_address;

  sc_core::sc_out<bool> mem_en,
                        pipe_en,
                        memA_wen,
                        memB_wen,
                        stage_finish;

  // Instances
  address_generator<ADDRESS_WIDTH, ADDRESS_WIDTH-1, STAGE_WIDTH> addr_gen;

  enable_generator en_gen;

  stage_counter<STAGE_WIDTH> stage_cnt;

  twiddle_generator<ADDRESS_WIDTH, STAGE_WIDTH> twid_gen;

  max_generator<NUMBER_OF_SUPPORTED_SAMPLE_SIZE, ADDRESS_WIDTH-1, STAGE_WIDTH> max_gen;

  // Internal signals
    sc_core::sc_signal<bool> internal_reset,
                             fft_finish_reset,
                             addr_gen_en,
                             stage_finish_internal,
                             pipe_en_internal,
                             mem_selector;

    sc_core::sc_signal<sc_dt::sc_uint<ADDRESS_WIDTH - 1> > max_count;

    sc_core::sc_signal<sc_dt::sc_uint<STAGE_WIDTH> > stage_count,
                                                     max_stage;

    sc_core::sc_signal<sc_dt::sc_uint<NUMBER_OF_SUPPORTED_SAMPLE_SIZE> > sample_width_selector;

    // TODO: create process for pipe_en_internal to split into mem_en and pipe_en
    // TODO: Create process to continuously assign stage_finish_internal to stage_finish
    // TODO: Create proces for generating internal_reset
    // TODO: Create process for assigning 5 MSbits to the sample_width_selector

    // Processes
    void cont_assign_pipe_en_internal();
    void cont_assign_stage_finish();
    void create_internal_reset();
    void cont_assign_sample_width_selector();
    void cont_assign_mem_selector();

  SC_CTOR(controller) : addr_gen("ADDR_GEN1"), en_gen("EN_GEN1"), stage_cnt("STAGE_CNT1"), twid_gen("TWID_GEN1"), max_gen("MAX_GEN1"){
    // Address Generator Binding
    addr_gen.clk(clk);
    addr_gen.reset(internal_reset);
    addr_gen.enable(addr_gen_en);
    addr_gen.max_count(max_count);
    addr_gen.stage_count(stage_count);
    addr_gen.stage_finish(stage_finish_internal);
    addr_gen.address_low(address_low);
    addr_gen.address_high(address_high);

    // Enable Generator Binding
    en_gen.clk(clk);
    en_gen.reset(internal_reset);
    en_gen.start(start);
    en_gen.mem_selector(mem_selector);
    en_gen.stage_finish(stage_finish_internal);
    en_gen.pipe_finish(pipe_finish);
    en_gen.addr_gen_en(addr_gen_en);
    en_gen.pipe_en(pipe_en_internal);
    en_gen.memA_wen(memA_wen);
    en_gen.memB_wen(memB_wen);

    // Stage Counter Binding
    stage_cnt.clk(clk);
    stage_cnt.reset(internal_reset);
    stage_cnt.enable(pipe_en_internal);
    stage_cnt.stage_finish(pipe_finish);
    stage_cnt.stage_cnt(stage_count);

    // Twiddle Generator Binding
    twid_gen.clk(clk);
    twid_gen.reset(internal_reset);
    twid_gen.enable(addr_gen_en);
    twid_gen.stage_count(stage_count);
    twid_gen.sample_number(number_of_samples);
    twid_gen.twiddle_address(twiddle_address);

    // Max generator Binding
    max_gen.sample_width_selector(sample_width_selector);
    max_gen.max_count(max_count);
    max_gen.max_stage(max_stage);


    // TODO: create process for pipe_en_internal to split into mem_en and pipe_en
    // TODO: Create process to continuously assign stage_finish_internal to stage_finish
    // TODO: Create proces for generating internal_reset
    // TODO: Create process for assigning 5 MSbits to the sample_width_selector

    // Processes
    SC_METHOD(cont_assign_pipe_en_internal);
      sensitive << pipe_en_internal;
    SC_METHOD(cont_assign_stage_finish);
      sensitive << stage_finish_internal;
    SC_METHOD(create_internal_reset);
      sensitive << reset << max_stage << pipe_finish << stage_count;
    SC_METHOD(cont_assign_sample_width_selector);
      sensitive << number_of_samples;
    SC_METHOD(cont_assign_mem_selector);
      sensitive << stage_count;
  }
};

void controller::cont_assign_pipe_en_internal(){
  mem_en.write(pipe_en_internal.read());
  pipe_en.write(pipe_en_internal.read());
}

void controller::cont_assign_stage_finish(){
  stage_finish.write(stage_finish_internal.read());
}

void controller::create_internal_reset(){
  internal_reset = reset.read() || ((max_stage.read() == stage_count.read()) && pipe_finish.read());
}

void controller::cont_assign_sample_width_selector(){
  sample_width_selector.write(number_of_samples.read().range(SAMPLE_WIDTH-1, SAMPLE_WIDTH-5));
}

void controller::cont_assign_mem_selector(){
  if(stage_count.read()[0]){
    mem_selector.write(true);
  } else {
    mem_selector.write(false);
  }
}

#endif

#include<systemc>
#include<iostream>
#ifndef EN_GEN_H
#define EN_GEN_H
SC_MODULE(enable_generator){
  // Inputs
  sc_core::sc_in_clk clk;
  sc_core::sc_in<bool> reset,
                       start,
                       mem_selector,
                       stage_finish,
                       pipe_finish;

  // Outputs
  sc_core::sc_out<bool> addr_gen_en,
                        pipe_en,
                        memA_wen,
                        memB_wen;

  // Internal variables
  bool internal_state, temp_internal_state;

  // Processes
  void generate_memx_en();
  void generate_pipe_en();
  void generate_addr_gen_en();
  void state_machine();

  SC_CTOR(enable_generator){
    SC_METHOD(generate_memx_en);
      sensitive << clk.pos();
    SC_METHOD(generate_pipe_en);
      sensitive << clk.pos();
    SC_METHOD(generate_addr_gen_en);
      sensitive << clk.pos();
    SC_METHOD(state_machine);
      sensitive << clk.pos();
  }
};

void enable_generator::generate_memx_en(){
  if(reset){
    memA_wen.write(false);
    memB_wen.write(false);
  } else if(start && !internal_state){
    memA_wen.write(false);
    memB_wen.write(true);
  } else if(pipe_finish && internal_state){
    memA_wen.write(mem_selector);
    memB_wen.write(!mem_selector);
  }
}

void enable_generator::generate_pipe_en(){
  if(reset){
    pipe_en.write(false);
  } else if(start && !internal_state){
    pipe_en.write(true);
  }
}

void enable_generator::generate_addr_gen_en(){
  std::cout << "In addr_gen_en" << internal_state << start << std::endl;
  if(reset){
    addr_gen_en.write(false);
  } else if(start && !internal_state){
    addr_gen_en.write(true);
  } else if(stage_finish && internal_state){
    addr_gen_en.write(false);
  } else if(pipe_finish && internal_state){
    addr_gen_en.write(true);
  }
}

void enable_generator::state_machine(){
  if(reset){
    internal_state = false;
    temp_internal_state = false;
  } else if(start){
    internal_state = temp_internal_state;
    temp_internal_state = true;
  }
}
#endif

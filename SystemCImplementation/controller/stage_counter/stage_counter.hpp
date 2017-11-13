#include<systemc>
#ifndef STAGE_CNT_H
#define STAGE_CNT_H
template<unsigned int stage_width>
SC_MODULE(stage_counter){
  // Inputs
  sc_core::sc_in_clk clk;
  sc_core::sc_in<bool> reset,
                       enable,
                       stage_finish;


  // Outputs
  sc_core::sc_out<sc_dt::sc_uint<stage_width> > stage_cnt;

  // Internal Var
  sc_dt::sc_uint<stage_width> stage_cnt_reg;
  // Process
  void count_stage();

  SC_CTOR(stage_counter){
    SC_METHOD(count_stage);
      sensitive << clk.pos();
  }
};

template<unsigned int stage_width>
void stage_counter<stage_width>::count_stage(){
  if(reset){
    stage_cnt_reg = 0;
  } else {
    if(enable && stage_finish){
      ++stage_cnt_reg;
    }
  }
  stage_cnt.write(stage_cnt_reg);
}
#endif

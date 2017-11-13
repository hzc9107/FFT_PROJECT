#include<systemc>
#ifndef MAX_VAL_GEN_H
#define MAX_VAL_GEN_H

#define SAMPLE_1024 1<<4
#define SAMPLE_512 1<<3
#define SAMPLE_256 1<<2
#define SAMPLE_128 1<<1
#define SAMPLE_64 1<<0

template<unsigned int number_sample_widths, unsigned int counter_width, unsigned int stage_width>
SC_MODULE(max_generator){
  // Inputs
  sc_core::sc_in<sc_dt::sc_uint<number_sample_widths> > sample_width_selector;

  // Outputs
  sc_core::sc_out<sc_dt::sc_uint<counter_width> > max_count;
  sc_core::sc_out<sc_dt::sc_uint<stage_width> > max_stage;

  // Processes
  void generate_max_values();

  SC_CTOR(max_generator){
    SC_METHOD(generate_max_values);
  }
};

template<unsigned int number_sample_widths, unsigned int counter_width, unsigned int stage_width>
void max_generator<number_sample_widths, counter_width, stage_width>::generate_max_values(){
  switch(sample_width_selector){
    case SAMPLE_1024:
      max_count.write(511);
      max_stage.write(9);
      break;
    case SAMPLE_512:
      max_count.write(255);
      max_stage.write(8);
      break;
    case SAMPLE_256:
      max_count.write(127);
      max_stage.write(7);
      break;
    case SAMPLE_128:
      max_count.write(63);
      max_stage.write(6);
      break;
    case SAMPLE_64:
      max_count.write(31);
      max_stage.write(5);
      break;
    default:
      max_count.write(0);
      max_stage.write(0);
      break;
  }
}

#endif

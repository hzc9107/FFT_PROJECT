#include<systemc>

#ifndef TWIDDLE_GENERATOR_H
#define TWIDDLE_GENERATOR_H

template<unsigned int address_width, unsigned int stage_width>
SC_MODULE(twiddle_generator){
  // Inputs
  sc_core::sc_in_clk clk;
  sc_core::sc_in<bool> reset, enable;
  sc_core::sc_in<sc_dt::sc_uint<stage_width> > stage_count;
  sc_core::sc_in<sc_dt::sc_uint<address_width + 1> > sample_number;
  // Outputs
  sc_core::sc_out<sc_dt::sc_uint<address_width> > twiddle_address;

  // Internals
  sc_dt::sc_uint<address_width> count, temp_twiddle_address;
  sc_dt::sc_uint<address_width> max_count, add_value;

  // Process
  void generate_max_count();
  void generate_address();
  void generate_add_value();

  SC_CTOR(twiddle_generator){
    SC_METHOD(generate_address);
      sensitive << clk.pos();
    SC_METHOD(generate_max_count);
      sensitive << stage_count;
    SC_METHOD(generate_add_value);
      sensitive << sample_number << stage_count;
  }
};

template<unsigned int address_width, unsigned int stage_width>
void twiddle_generator<address_width, stage_width>::generate_add_value(){
  add_value = 0;
  switch(stage_count.read()){
    case 1:
      add_value = sample_number.read() >> 2;
      break;
    case 2:
      add_value = sample_number.read() >> 3;
      break;
    case 3:
      add_value = sample_number.read() >> 4;
      break;
    case 4:
      add_value = sample_number.read() >> 5;
      break;
    case 5:
      add_value = sample_number.read() >> 6;
      break;
    case 6:
      add_value = sample_number.read() >> 7;
      break;
    case 7:
      add_value = sample_number.read() >> 8;
      break;
    case 8:
      add_value = sample_number.read() >> 9;
      break;
    case 9:
      add_value = sample_number.read() >> 10;
      break;
    default:
      break;
  }
}

template<unsigned int address_width, unsigned int stage_width>
void twiddle_generator<address_width, stage_width>::generate_max_count(){
  max_count = 0;
  switch(stage_count.read()){
    case 1:
      max_count = 1;
      break;
    case 2:
      max_count = 3;
      break;
    case 3:
      max_count = 7;
      break;
    case 4:
      max_count = 15;
      break;
    case 5:
      max_count = 31;
      break;
    case 6:
      max_count = 63;
      break;
    case 7:
      max_count = 127;
      break;
    case 8:
      max_count = 255;
      break;
    case 9:
      max_count = 511;
      break;
    default:
      break;
  }
}

template<unsigned int address_width, unsigned int stage_width>
void twiddle_generator<address_width, stage_width>::generate_address(){
  if(reset){
    count = 0;
    temp_twiddle_address = 0;
  } else {
    if(enable){
      if(count == max_count){
        count = 0;
        temp_twiddle_address = 0;
      } else {
        temp_twiddle_address += add_value;
        ++count;
      }
    }
  }
  twiddle_address.write(temp_twiddle_address);
}

#endif

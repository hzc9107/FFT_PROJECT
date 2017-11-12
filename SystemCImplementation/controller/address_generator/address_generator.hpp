#include<systemc>

#ifndef ADDR_GENERATOR_H
#define ADDR_GENERATOR_H

#define COUNT_MASK_1024 1<<8
#define COUNT_MASK_512 1<<7
#define COUNT_MASK_256 1<<6
#define COUNT_MASK_128 1<<5
#define COUNT_MASK_64 1<<4

template<unsigned int address_width, unsigned int counter_width, unsigned int stage_width>
SC_MODULE(address_generator){
  // Inputs
  sc_core::sc_in_clk clk;
  sc_core::sc_in<bool> reset, enable;
  sc_core::sc_in<sc_dt::sc_uint<counter_width> > max_count;
  sc_core::sc_in<sc_dt::sc_uint<stage_width> > stage_count;

  // Outputs
  sc_core::sc_out<bool> stage_finish;
  sc_core::sc_out<sc_dt::sc_uint<address_width> > address_low, address_high;

  // Internal
  sc_core::sc_signal<sc_dt::sc_uint<counter_width> > count;

  // Process
  void generate_address();
  void generate_finish_signal();
  void exec_count();

  SC_CTOR(address_generator){
    SC_METHOD(generate_address);
      sensitive << max_count << stage_count << count;
    SC_METHOD(exec_count);
      sensitive << clk.pos();
    SC_METHOD(generate_finish_signal);
      sensitive << count << enable << max_count;
  }
};

template<unsigned int address_width, unsigned int counter_width, unsigned int stage_width>
void address_generator<address_width, counter_width, stage_width>::generate_finish_signal(){
  if(max_count == count && enable){
    stage_finish.write(true);
  } else {
    stage_finish.write(false);
  }
}


template<unsigned int address_width, unsigned int counter_width, unsigned int stage_width>
void address_generator<address_width, counter_width, stage_width>::generate_address(){
  int max_number_of_stages = 0;
  sc_dt::sc_uint<address_width> temp_address_low = 0,
                                temp_address_high = 0;
  sc_dt::sc_uint<counter_width> count_temp = count.read();
  if(max_count.read() & COUNT_MASK_1024){
    max_number_of_stages = 9;
    switch(stage_count.read()){
      case 0:
        temp_address_high[9] = 1;
        temp_address_high.range(8,0) = count_temp;
        temp_address_low.range(8,0) = count_temp;
        break;
      case 1:
        temp_address_high[8] = 1;
        temp_address_high[9] = count_temp[8];
        temp_address_low[9]  = count_temp[8];
        temp_address_high.range(7,0) = count_temp.range(7,0);
        temp_address_low.range(7,0)  = count_temp.range(7,0);
        break;
      case 2:
        temp_address_high[7] = 1;
        temp_address_high.range(9,8) = count_temp.range(8,7);
        temp_address_low.range(9,8)  = count_temp.range(8,7);
        temp_address_high.range(6,0) = count_temp.range(6,0);
        temp_address_low.range(6,0)  = count_temp.range(6,0);
        break;
      case 3:
        temp_address_high[6] = 1;
        temp_address_high.range(9,7) = count_temp.range(8,6);
        temp_address_low.range(9,7) = count_temp.range(8,6);
        temp_address_high.range(5,0) = count_temp.range(5,0);
        temp_address_low.range(5,0) = count_temp.range(5,0);
        break;
      case 4:
        temp_address_high[5] = 1;
        temp_address_high.range(9,6) = count_temp.range(8,5);
        temp_address_low.range(9,6)  = count_temp.range(8,5);
        temp_address_high.range(4,0) = count_temp.range(4,0);
        temp_address_low.range(4,0)  = count_temp.range(4,0);
        break;
      case 5:
        temp_address_high[4] = 1;
        temp_address_high.range(9,5) = count_temp.range(8,4);
        temp_address_low.range(9,5)  = count_temp.range(8,4);
        temp_address_high.range(3,0) = count_temp.range(3,0);
        temp_address_low.range(3,0)  = count_temp.range(3,0);
        break;
      case 6:
        temp_address_high[3] = 1;
        temp_address_high.range(9,4) = count_temp.range(8,3);
        temp_address_low.range(9,4)  = count_temp.range(8,3);
        temp_address_high.range(2,0) = count_temp.range(2,0);
        temp_address_low.range(2,0)  = count_temp.range(2,0);
        break;
      case 7:
        temp_address_high[2] = 1;
        temp_address_high.range(9,3) = count_temp.range(8,2);
        temp_address_low.range(9,3)  = count_temp.range(8,2);
        temp_address_low.range(1,0)  = count_temp.range(1,0);
        temp_address_high.range(1,0) = count_temp.range(1,0);
        break;
      case 8:
        temp_address_high[1] = 1;
        temp_address_high.range(9,2) = count_temp.range(8,1);
        temp_address_low.range(9,2)  = count_temp.range(8,1);
        temp_address_high[0] = count_temp[0];
        temp_address_low[0]  = count_temp[0];
        break;
      case 9:
        temp_address_high[0] = 1;
        temp_address_high.range(9,1) = count_temp.range(8,0);
        temp_address_low.range(9,1)  = count_temp.range(8,0);
        break;
      default:
        break;
    }
  } else if(max_count.read() & COUNT_MASK_512){
    switch(stage_count.read()){
      case 0:
        temp_address_high[8] = 1;
        temp_address_high.range(7,0) = count_temp.range(7,0);
        temp_address_low.range(7,0) = count_temp.range(7,0);
        break;
      case 1:
        temp_address_high[7] = 1;
        temp_address_high[8] = count_temp[7];
        temp_address_low[8] = count_temp[7];
        temp_address_high.range(6,0) = count_temp.range(6,0);
        temp_address_low.range(6,0) = count_temp.range(6,0);
        break;
      case 2:
        temp_address_high[6] = 1;
        temp_address_high.range(8,7) = count_temp.range(7,6);
        temp_address_low.range(8,7) = count_temp.range(7,6);
        temp_address_high.range(5,0) = count_temp.range(5,0);
        temp_address_low.range(5,0) = count_temp.range(5,0);
        break;
      case 3:
        temp_address_high[5] = 1;
        temp_address_high.range(8,6) = count_temp.range(7,5);
        temp_address_low.range(8,6) = count_temp.range(7,5);
        temp_address_high.range(4,0) = count_temp.range(4,0);
        temp_address_low.range(4,0) = count_temp.range(4,0);
        break;
      case 4:
        temp_address_high[4] = 1;
        temp_address_high.range(8,5) = count_temp.range(7,4);
        temp_address_low.range(8,5) = count_temp.range(7,4);
        temp_address_high.range(3,0) = count_temp.range(3,0);
        temp_address_low.range(3,0) = count_temp.range(3,0);
        break;
      case 5:
        temp_address_high[3] = 1;
        temp_address_high.range(8,4) = count_temp.range(7,3);
        temp_address_low.range(8,4) = count_temp.range(7,3);
        temp_address_high.range(2,0) = count_temp.range(2,0);
        temp_address_low.range(2,0) = count_temp.range(2,0);
        break;
      case 6:
        temp_address_high[2] = 1;
        temp_address_high.range(8,3) = count_temp.range(7,2);
        temp_address_low.range(8,3) = count_temp.range(7,2);
        temp_address_high.range(1,0) = count_temp.range(1,0);
        temp_address_low.range(1,0) = count_temp.range(1,0);
        break;
      case 7:
        temp_address_high[1] = 1;
        temp_address_high.range(8,2) = count_temp.range(7,1);
        temp_address_low.range(8,2) = count_temp.range(7,1);
        temp_address_high[0] = count_temp[0];
        temp_address_low[0] = count_temp[0];
        break;
      case 8:
        temp_address_high[0] = 1;
        temp_address_high.range(8,1) = count_temp.range(7,0);
        temp_address_low.range(8,1) = count_temp.range(7,0);
        break;
      default:
        break;
    }
  } else if(max_count.read() & COUNT_MASK_256){
    switch(stage_count.read()){
      case 0:
        temp_address_high[7] = 1;
        temp_address_high.range(6,0) = count_temp.range(6,0);
        temp_address_low.range(6,0) = count_temp.range(6,0);
        break;
      case 1:
        temp_address_high[6] = 1;
        temp_address_high[7] = count_temp[6];
        temp_address_low[7] = count_temp[6];
        temp_address_high.range(5,0) = count_temp.range(5,0);
        temp_address_low.range(5,0) = count_temp.range(5,0);
        break;
      case 2:
        temp_address_high[5] = 1;
        temp_address_high.range(7,6) = count_temp.range(6,5);
        temp_address_low.range(7,6) = count_temp.range(6,5);
        temp_address_high.range(4,0) = count_temp.range(4,0);
        temp_address_low.range(4,0) = count_temp.range(4,0);
        break;
      case 3:
        temp_address_high[4] = 1;
        temp_address_high.range(7,5) = count_temp.range(6,4);
        temp_address_low.range(7,5) = count_temp.range(6,4);
        temp_address_high.range(3,0) = count_temp.range(3,0);
        temp_address_low.range(3,0) = count_temp.range(3,0);
        break;
      case 4:
        temp_address_high[3] = 1;
        temp_address_high.range(7,4) = count_temp.range(6,3);
        temp_address_low.range(7,4) = count_temp.range(6,3);
        temp_address_high.range(2,0) = count_temp.range(2,0);
        temp_address_low.range(2,0) = count_temp.range(2,0);
        break;
      case 5:
        temp_address_high[2] = 1;
        temp_address_high.range(7,3) = count_temp.range(6,2);
        temp_address_low.range(7,3) = count_temp.range(6,2);
        temp_address_high.range(1,0) = count_temp.range(1,0);
        temp_address_low.range(1,0) = count_temp.range(1,0);
        break;
      case 6:
        temp_address_high[1] = 1;
        temp_address_high.range(7,2) = count_temp.range(6,1);
        temp_address_low.range(7,2) = count_temp.range(6,1);
        temp_address_high[0] = count_temp[0];
        temp_address_low[0] = count_temp[0];
        break;
      case 7:
        temp_address_high[0] = 1;
        temp_address_high.range(7,1) = count_temp.range(6,0);
        temp_address_low.range(7,1) = count_temp.range(6,0);
        break;
      default:
        temp_address_high = 0;
        temp_address_low  = 0;
        break;
    }
  } else if(max_count.read() & COUNT_MASK_128){
    switch(stage_count.read()){
      case 0:
        temp_address_high[6] = 1;
        temp_address_high.range(5,0) = count_temp.range(5,0);
        temp_address_low.range(5,0) = count_temp.range(5,0);
        break;
      case 1:
        temp_address_high[5] = 1;
        temp_address_high[6] = count_temp[5];
        temp_address_low[6] = count_temp[5];
        temp_address_high.range(4,0) = count_temp.range(4,0);
        temp_address_low.range(4,0) = count_temp.range(4,0);
        break;
      case 2:
        temp_address_high[4] = 1;
        temp_address_high.range(6,5) = count_temp.range(5,4);
        temp_address_low.range(6,5) = count_temp.range(5,4);
        temp_address_high.range(3,0) = count_temp.range(3,0);
        temp_address_low.range(3,0) = count_temp.range(3,0);
        break;
      case 3:
        temp_address_high[3] = 1;
        temp_address_high.range(6,4) = count_temp.range(5,3);
        temp_address_low.range(6,4) = count_temp.range(5,3);
        temp_address_high.range(2,0) = count_temp.range(2,0);
        temp_address_low.range(2,0) = count_temp.range(2,0);
        break;
      case 4:
        temp_address_high[2] = 1;
        temp_address_high.range(6,3) = count_temp.range(5,2);
        temp_address_low.range(6,3) = count_temp.range(5,2);
        temp_address_high.range(1,0) = count_temp.range(1,0);
        temp_address_low.range(1,0) = count_temp.range(1,0);
        break;
      case 5:
        temp_address_high[1] = 1;
        temp_address_high.range(6,2) = count_temp.range(5,1);
        temp_address_low.range(6,2) = count_temp.range(5,1);
        temp_address_high[0] = count_temp[0];
        temp_address_low[0] = count_temp[0];
        break;
      case 6:
        temp_address_high[0] = 1;
        temp_address_high.range(6,1) = count_temp.range(5,0);
        temp_address_low.range(6,1) = count_temp.range(5,0);
        break;
      default:
        break;
    }
  } else if(max_count.read() & COUNT_MASK_64){
    switch(stage_count.read()){
      case 0:
        temp_address_high[5] = 1;
        temp_address_high.range(4,0) = count_temp.range(4,0);
        temp_address_low.range(4,0) = count_temp.range(4,0);
        break;
      case 1:
        temp_address_high[4] = 1;
        temp_address_high[5] = count_temp[4];
        temp_address_low[5] = count_temp[4];
        temp_address_high.range(3,0) = count_temp.range(3,0);
        temp_address_low.range(3,0) = count_temp.range(3,0);
        break;
      case 2:
        temp_address_high[3] = 1;
        temp_address_high.range(5,4) = count_temp.range(4,3);
        temp_address_low.range(5,4) = count_temp.range(4,3);
        temp_address_high.range(2,0) = count_temp.range(2,0);
        temp_address_low.range(2,0) = count_temp.range(2,0);
        break;
      case 3:
        temp_address_high[2] = 1;
        temp_address_high.range(5,3) = count_temp.range(4,2);
        temp_address_low.range(5,3) = count_temp.range(4,2);
        temp_address_high.range(1,0) = count_temp.range(1,0);
        temp_address_low.range(1,0) = count_temp.range(1,0);
        break;
      case 4:
        temp_address_high[1] = 1;
        temp_address_high.range(5,2) = count_temp.range(4,1);
        temp_address_low.range(5,2) = count_temp.range(4,1);
        temp_address_high[0] = count_temp[0];
        temp_address_low[0] = count_temp[0];
        break;
      case 5:
        temp_address_high[0] = 1;
        temp_address_high.range(5,1) = count_temp(4,0);
        temp_address_low.range(5,1) = count_temp.range(4,0);
        break;
      default:
        break;
    }
  }
  address_low.write(temp_address_low);
  address_high.write(temp_address_high);
}

template<unsigned int address_width, unsigned int counter_width, unsigned int stage_width>
void address_generator<address_width, counter_width, stage_width>::exec_count(){
  if(reset){
    count.write(0);
  } else {
    if(enable){
      if(count.read() == max_count.read()){
        count.write(0);
      } else {
        count.write(count.read()+1);
      }
    }
  }
}
#endif

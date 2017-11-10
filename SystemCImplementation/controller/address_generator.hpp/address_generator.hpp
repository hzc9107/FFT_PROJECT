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
  sc_dt::sc_uint<counter_width> counter;

  // Process
  void generate_address();
  void count();

  SC_CTOR(address_generator){
    SC_METHOD(generate_address);
      sensitive << clk.pos();
    SC_METHOD(count);
      sensitive << clk.pos();
  }
};

template<unsigned int address_width, unsigned int counter_width, unsigned int stage_width>
void address_generator<address_width, counter_width, stage_width>::generate_address(){
  if(reset){
    address_low.write(0);
    address_high.write(0);
  } else {
    int max_number_of_stages = 0;
    sc_dt::sc_uint<address_width> temp_address_low = 0,
                                  temp_address_high = 0;
    if(enable){
      if(max_count & COUNT_MASK_1024){
        max_number_of_stages = 9;
        switch(stage_count.read()){
          case 0:
            temp_address_high[9] = 1;
            temp_address_high.range(8,0) = count;
            temp_address_low.range(8,0) = count;
            break;
          case 1:
            temp_address_high[8] = 1;
            temp_address_high.[9] = count[8];
            temp_address_low.[9]  = count[8];
            temp_address_high.range(7,0) = count.range(7,0);
            temp_address_low.range(7,0)  = count.range(7,0);
            break;
          case 2:
            temp_address_high[7] = 1;
            temp_address_high.range(9,8) = count.range(8,7);
            temp_address_low.range(9,8)  = count.range(8,7);
            temp_address_high.range(6,0) = count.range(6,0);
            temp_address_low.range(6,0)  = count.range(6,0);
            break;
          case 3:
            temp_address_high[6] = 1;
            temp_address_high.range(9,7) = count.range(8,6);
            temp_address_low.range(9,7) = count.range(8,6);
            temp_address_high.range(5,0) = count.range(5,0);
            temp_address_low.range(5,0) = count.range(5,0);
            break;
          case 4:
            temp_address_high[5] = 1;
            temp_address_high.range(9,6) = count.range(8,5);
            temp_address_low.range(9,6)  = count.range(8,5);
            temp_address_high.range(4,0) = count.range(4,0);
            temp_address_low.range(4,0)  = count.range(4,0);
            break;
          case 5:
            temp_address_high[4] = 1;
            temp_address_high.range(9,5) = count.range(8,4);
            temp_address_low.range(9,5)  = count.range(8,4);
            temp_address_high.range(3,0) = count.range(3,0);
            temp_address_low.range(3,0)  = count.range(3,0);
            break;
          case 6:
            temp_address_high[3] = 1;
            temp_address_high.range(9,4) = count.range(8,3);
            temp_address_low.range(9,4)  = count.range(8,3);
            temp_address_high.range(2,0) = count.range(2,0);
            temp_address_low.range(2,0)  = count.range(2,0);
            break;
          case 7:
            temp_address_high[2] = 1;
            temp_address_high.range(9,3) = count.range(8,2);
            temp_address_low.range(9,3)  = count.range(8,2);
            temp_address_low.range(1,0)  = count.range(1,0);
            temp_address_high.range(1,0) = count.range(1,0);
            break;
          case 8:
            temp_address_high[1] = 1;
            temp_address_high.range(9,2) = count.range(8,1);
            temp_address_low.range(9,2)  = count.range(8,1);
            temp_address_high[0] = count[0];
            temp_address_low[0]  = count[0];
            break;
          case 9:
            temp_address_high[0] = 1;
            temp_address_high.range(9,1) = count.range(8,0);
            temp_address_low.range(9,1)  = count.range(8,0);
            break;
          default:
            break;
        }
      } else if(max_count & COUNT_MASK_512){
        switch(stage_count.read()){
          case 0:
            temp_address_high[8] = 1;
            temp_address_high.range(7,0) = count.range(7,0);
            temp_address_low.range(7,0) = count.range(7,0);
            break;
          case 1:
            temp_address_high[7] = 1;
            temp_address_high[8] = count[7];
            temp_address_low[8] = count[7];
            temp_address_high.range(6,0) = count.range(6,0);
            temp_address_low.range(6,0) = count.range(6,0);
            break;
          case 2:
            temp_address_high[6] = 1;
            temp_address_high.range(8,7) = count.range(7,6);
            temp_address_low.range(8,7) = count.range(7,6);
            temp_address_high.range(5,0) = count.range(5,0);
            temp_address_low.range(5,0) = count.range(5,0);
            break;
          case 3:
            temp_address_high[5] = 1;
            temp_address_high.range(8,6) = count.range(7,5);
            temp_address_low.range(8,6) = count.range(7,5);
            temp_address_high.range(4,0) = count.range(4,0);
            temp_address_low.range(4,0) = count.range(4,0);
            break;
          case 4:
            temp_address_high[4] = 1;
            temp_address_high.range(8,5) = count.range(7,4);
            temp_address_low.range(8,5) = count.range(7,4);
            temp_address_high.range(3,0) = count.range(3,0);
            temp_address_low.range(3,0) = count.range(3,0);
            break;
          case 5:
            temp_address_high[3] = 1;
            temp_address_high.range(8,4) = count.range(7,3);
            temp_address_low.range(8,4) = count.range(7,3);
            temp_address_high.range(2,0) = count.range(2,0);
            temp_address_low.range(2,0) = count.range(2,0);
            break;
          case 6:
            temp_address_high[2] = 1;
            temp_address_high.range(8,3) = count.range(7,2);
            temp_address_low.range(8,3) = count.range(7,2);
            temp_address_high.range(1,0) = count.range(1,0);
            temp_address_low.range(1,0) = count.range(1,0);
            break;
          case 7:
            temp_address_high[1] = 1;
            temp_address_high.range(8,2) = count.range(7,1);
            temp_address_low.range(8,2) = count.range(7,1);
            temp_address_high[0] = count[0];
            temp_address_low[0] = count[0];
            break;
          case 8:
            temp_address_high[0] = 1;
            temp_address_high.range(8,1) = count.range(7,0);
            temp_address_low.range(8,1) = count.range(7,0);
            break;
          default:
            break;
        }
      } else if(max_count & COUNT_MASK_256){
        switch(stage_count.read()){
          case 0:
            temp_address_high[7] = 1;
            temp_address_high.range(6,0) = count.range(6,0);
            temp_address_low.range(6,0) = count.range(6,0);
            break;
          case 1:
            temp_address_high[6] = 1;
            temp_address_high[7] = count[6];
            temp_address_low[7] = count[6];
            temp_address_high.range(5,0) = count.range(5,0);
            temp_address_low.range(5,0) = count.range(5,0);
            break;
          case 2:
            temp_address_high[5] = 1;
            temp_address_high.range(7,6) = count.range(6,5);
            temp_address_low.range(7,6) = count.range(6,5);
            temp_address_high.range(4,0) = count.range(4,0);
            temp_address_low.range(4,0) = count.range(4,0);
            break;
          case 3:
            temp_address_high[4] = 1;
            temp_address_high.range(7,5) = count.range(6,4);
            temp_address_low.range(7,5) = count.range(6,4);
            temp_address_high.range(3,0) = count.range(3,0);
            temp_address_low.range(3,0) = count.range(3,0);
            break;
          case 4:
            temp_address_high[3] = 1;
            temp_address_high.range(7,4) = count.range(6,3);
            temp_address_low.range(7,4) = count.range(6,3);
            temp_address_high.range(2,0) = count.range(2,0);
            temp_address_low.range(2,0) = count.range(2,0);
            break;
          case 5:
            temp_address_high[2] = 1;
            temp_address_high.range(7,3) = count.range(6,2);
            temp_address_low.range(7,3) = count.range(6,2);
            temp_address_high.range(1,0) = count.range(1,0);
            temp_address_low.range(1,0) = count.range(1,0);
            break;
          case 6:
            temp_address_high[1] = 1;
            temp_address_high.range(7,2) = count.range(6,1);
            temp_address_low.range(7,2) = count.range(6,1);
            temp_address_high[0] = count[0];
            temp_address_low[0] = count[0];
            break;
          case 7:
            temp_address_high[0] = 1;
            temp_address_high.range(7,1) = count.range(6,0);
            temp_address_low.range(7,1) = count.range(6,0);
            break;
          default:
            temp_address_high = 0;
            temp_address_low  = 0;
            break;
        }
      } else if(max_count & COUNT_MASK_128){
        switch(stage_count.read()){
          case 0:
            temp_address_high[6] = 1;
            temp_address_high.range(5,0) = count.range(5,0);
            temp_address_low.range(5,0) = count.range(5,0);
            break;
          case 1:
            temp_address_high[5] = 1;
            temp_address_high[6] = count[5];
            temp_address_low[6] = count[5];
            temp_address_high.range(4,0) = count.range(4,0);
            temp_address_low.range(4,0) = count.range(4,0);
            break;
          case 2:
            temp_address_high[4] = 1;
            temp_address_high.range(6,5) = count.range(5,4);
            temp_address_low.range(6,5) = count.range(5,4);
            temp_address_high.range(3,0) = count.range(3,0);
            temp_address_low.range(3,0) = count.range(3,0);
            break;
          case 3:
            temp_address_high[3] = 1;
            temp_address_high.range(6,4) = count.range(5,3);
            temp_address_low.range(6,4) = count.range(5,3);
            temp_address_high.range(2,0) = count.range(2,0);
            temp_address_low.range(2,0) = count.range(2,0);
            break;
          case 4:
            temp_address_high[2] = 1;
            temp_address_high.range(6,3) = count.range(5,2);
            temp_address_low.range(6,3) = count.range(5,2);
            temp_address_high.range(1,0) = count.range(1,0);
            temp_address_low.range(1,0) = count.range(1,0);
            break;
          case 5:
            temp_address_high[1] = 1;
            temp_address_high.range(6,2) = count.range(5,1);
            temp_address_low.range(6,2) = count.range(5,1);
            temp_address_high[0] = count[0];
            temp_address_low[0] = count[0];
            break;
          case 6:
            temp_address_high[0] = 1;
            temp_address_high.range(6,1) = count.range(5,0);
            temp_address_low.range(6,1) = count.range(5,0);
            break;
          default:
            break;
        }
      } else if(max_count & COUNT_MASK_64){
        switch(stage_count.read()){
          case 0:
            temp_address_high[5] = 1;
            temp_address_high.range(4,0) = count.range(4,0);
            temp_address_low.range(4,0) = count.range(4,0);
            break;
          case 1:
            temp_address_high[4] = 1;
            temp_address_high[5] = count[4];
            temp_address_low[5] = count[4];
            temp_address_high.range(3,0) = count.range(3,0);
            temp_address_low.range(3,0) = count.range(3,0);
            break;
          case 2:
            temp_address_high[3] = 1;
            temp_address_high.range(5,4) = count.range(4,3);
            temp_address_low.range(5,4) = count.range(4,3);
            temp_address_high.range(2,0) = count.range(2,0);
            temp_address_low.range(2,0) = count.range(2,0);
            break;
          case 3:
            temp_address_high[2] = 1;
            temp_address_high.range(5,3) = count.range(4,2);
            temp_address_low.range(5,3) = count.range(4,2);
            temp_address_high.range(1,0) = count.range(1,0);
            temp_address_low.range(1,0) = count.range(1,0);
            break;
          case 4:
            temp_address_high[1] = 1;
            temp_address_high.range(5,2) = count.range(4,1);
            temp_address_low.range(5,2) = count.range(4,1);
            temp_address_high[0] = count[0];
            temp_address_low[0] = count[0];
            break;
          case 5:
            temp_address_high[0] = 1;
            temp_address_high.range(5,1) = count(4,0);
            temp_address_low.range(5,1) = count.range(4,0);
            break;
          default:
            break;
        }
      }
      address_low.write(temp_address_low);
      address_high.write(temp_address_high);
    }
  }
}

template<unsigned int address_width, unsigned int counter_width, unsigned int stage_width>
void address_generator<address_width, counter_width, stage_width>::count(){
  if(reset){
    count = 0;
    stage_finish.write(false);
  } else {
    if(enable){
      if(count == max_count.read()){
        count = 0;
        stage_finish.write(true);
      } else {
        ++count;
        stage_finish.write(false);
      }
    }
  }
}
#endif

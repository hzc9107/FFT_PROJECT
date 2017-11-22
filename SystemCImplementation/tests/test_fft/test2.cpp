#include<systemc>
#include<iostream>
int sc_main(int argc, char *argv[]){
  sc_dt::sc_int<16> val1, val2;
  sc_dt::sc_int<8> result;
  val1 = 0x30; val2 = 1<<15;
  std::cout << val1*val2 << " " << ((val1 * val2) >> 16) << " " << std:: hex << val1*val2 << " " << std::hex <<  ((val1 * val2) >> 16) <<   std::endl;
}

#include"systemc"
#include<fstream>
#include<string>
#include<iostream>
#ifndef DUAL_PORT_MEM_H
#define DUAL_PORT_MEM_H
template<unsigned int data_width = 32, unsigned int address_width = 2>
SC_MODULE(dual_port_memory){
  // Input Signal Definitions
  sc_core::sc_in<sc_dt::sc_int<data_width> > dataA, dataB;
  sc_core::sc_in<sc_dt::sc_uint<address_width> > addressA, addressB;
  sc_core::sc_in<bool> memEnable, writeAEn, writeBEn;
  sc_core::sc_in_clk clk;

  // Output Signal Definitions
  sc_core::sc_out<sc_dt::sc_int<data_width> > dataAOut, dataBOut;

  // Internal Variables
  sc_dt::sc_int<data_width> memory[1 << address_width];

  // Processes
  /* Write Process */
  void write();
  /* Read Process */
  void read();

  /*Read test values**/
  void read_vector_from_file(std::string fileName);

  /*Write test values*/
  void write_memory_to_file(std::string fileName);

  SC_CTOR(dual_port_memory){
    SC_METHOD(write);
    sensitive_pos << clk;

    SC_METHOD(read);
    sensitive_pos << clk;
  }
};

template<unsigned int data_width, unsigned int address_width>
void dual_port_memory<data_width,address_width>::write_memory_to_file(
  std::string fileName
) {
  std::ofstream outputFile(fileName);
  for(int i = 0; i < (1<<address_width); ++i){
    outputFile << i << ": " << std::hex << memory[i] << std::endl;
  }
  outputFile.close();
}

template<unsigned int data_width, unsigned int address_width>
void dual_port_memory<data_width,address_width>::read_vector_from_file(
  std::string fileName
){
  std::ifstream test_file(fileName);
  unsigned int index = 0;
  std::string line;
  while(getline(test_file, line)){
      unsigned int prueba = 0;
    try{
      prueba = static_cast<unsigned int>(std::stoul(line));
    } catch(const std::invalid_argument &arg) {
      std::cerr << "ERROR: " << line << std::endl;
    } catch(const std::out_of_range &arg){
      std::cerr << "ERROR: " << line << std::endl;
    }

    memory[index++] = prueba;
  }
}

template<unsigned int data_width, unsigned int address_width>
void dual_port_memory<data_width,address_width>::write(){
  if(memEnable.read()){
    if(writeAEn.read() || writeBEn.read()){
      memory[addressA.read()] = (writeAEn.read()) ? dataA.read() : memory[addressA.read()];
      memory[addressB.read()] = (writeBEn.read()) ? dataB.read() : memory[addressB.read()];
    }
  }
}

template<unsigned int data_width, unsigned int address_width>
void dual_port_memory<data_width,address_width>::read(){
  if(memEnable.read()){
    if(addressA.read() == addressB.read() && (writeAEn || writeBEn)){
      sc_dt::sc_int<data_width> valueToWrite = memory[addressA.read()];
      valueToWrite = (writeAEn.read()) ? dataA.read() : valueToWrite;
      valueToWrite = (writeBEn.read()) ? dataB.read() : valueToWrite;
      dataAOut.write(valueToWrite);
      dataBOut.write(valueToWrite);
    } else {
      dataAOut.write((writeAEn.read() ? dataA.read() : memory[addressA.read()]));
      dataBOut.write((writeBEn.read() ? dataB.read() : memory[addressB.read()]));
    }
 }
}

#endif

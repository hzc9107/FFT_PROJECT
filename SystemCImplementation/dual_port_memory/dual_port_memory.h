#include"systemc"
template<unsigned int data_width = 32, unsigned int address_width = 2>
SC_MODULE(dual_port_memory){
  // Input Signal Definitions
  sc_core::sc_in<sc_dt::sc_uint<data_width> > dataA, dataB;
  sc_core::sc_in<sc_dt::sc_uint<address_width> > addressA, addressB;
  sc_core::sc_in<bool> memEnable, writeAEn, writeBEn;
  sc_core::sc_in_clk clk;

  // Output Signal Definitions
  sc_core::sc_out<sc_dt::sc_uint<data_width> > dataAOut, dataBOut;

  // Internal Variables
  sc_dt::sc_uint<data_width> memory[1 << address_width];

  // Processes
  /* Write Process */
  void write();
  /* Read Process */
  void read();

  SC_CTOR(dual_port_memory){
    SC_METHOD(write);
    sensitive_pos << clk;

    SC_METHOD(read);
    sensitive_pos << clk;
  }
};

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
      sc_dt::sc_uint<data_width> valueToWrite = memory[addressA.read()];
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

#include<fstream>
#include<string>
#include<iostream>
int main(int argc, char *argv[]){
  std::ifstream file(argv[1]);
  int ar, ai, br, bi, wr, wi, aor, aoi, bor, boi;
  while(!file.eof()){
    file >>  ar >> ai >> br >> bi >> wr >> wi >> aor >> aoi >> bor >> boi;
    std::cout << ar << " " << ai << " " << br << " " << bi << " " << wr << " " << wi << " " << aor << " " << aoi << " " << bor << " " << boi << std::endl;
  }
  std::cout << ar << std::endl;
  file.close();
}

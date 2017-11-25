#include<cstdio>
#include<cstdlib>
#include<iostream>
#include<string>

int main(int argc, char *argv[]){
  if(freopen("input.txt", "r", stdin) == NULL){
    perror("freopen() failed");
    return EXIT_FAILURE;
  } 
  int widthOfNumber, sizeOfSamples;
  std::cin >> widthOfNumber >> sizeOfSamples;
  std::string binNumber;
  while(sizeOfSamples--){
    std::cin >> binNumber;
    std::cout << binNumber << std::endl;
    int realNumber = 0, imagNumber = 0;
    for(int j = 0; j < widthOfNumber; j++){
      int value = (binNumber[j] == '1') ? 1 : 0;
      int multiplier = 1 << (widthOfNumber-1 - j);
      if(j == 0){
       multiplier *= -1; 
      }
      realNumber += (multiplier*value);
   }
    for(int i = widthOfNumber; i < binNumber.length(); ++i){
      int value = (binNumber[i] == '1') ? 1 : 0;
      int multiplier = 1 << (widthOfNumber-1 - (i-widthOfNumber));
      if(i == widthOfNumber){
       multiplier *= -1; 
      }
      imagNumber += (multiplier*value);
    }
    std::cout << "Real: " << realNumber << " Imag: " << imagNumber << std::endl;
  }
  fclose(stdin); 
}

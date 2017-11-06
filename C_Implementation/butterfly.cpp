#include<iostream>
#include<vector>
#include<algorithm>

std::vector<std::pair<int, int> > twiddleIndexes;

void multiply(
  std::pair<int, int> &operand,
  int twiddleIndex
){
  int factor1 = 
  operand.first = twiddleIndexes[twiddleIndex].first
}

std::vector<std::pair<int, int> > performButterfly(
  std::pair<int, int> &operand1,
  std::pair<int, int> &operand2,
  int twiddleIndex 
){
  std::vector<std::pair<int, int> > result;
  std::pair<int, int> upperhalf, lowerhalf;
  
  upperhalf.first  =  (operand1.first  + operand2.first);
  upperhalf.second =  (operand1.second + operand2.second);
  
  lowerhalf.first  = (operand1.first  - operand2.first);
  upperhalf.second = (operand1.second - operand2.second); 

  multiply(
    lowerhalf,
    twiddleIndex
  );

  return result;
}


int main(){
  
}

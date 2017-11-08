sampleValues = rem(floor(rand(16)*10000), ones(16) * 2047)(1, :) + rem(floor(rand(16)*10000), ones(16) * 2047)(1, :)*i;
twiddleFactors = rem(floor(rand(16)*100000), ones(16) * 32760)(1, :)+rem(floor(rand(16)*100000), ones(16) * 32760)(1, :)*i;
fid = fopen("testFIle.ssv", "w");
for j = 1:8
  mult   = twiddleFactors(j)*sampleValues(j+8);
  realMult   = bitshift(real(mult),-16);
  imagMult = bitshift(imag(mult), -16);
  mult2 = realMult + imagMult*i;
  result1 = sampleValues(j) + mult2;
  result2 = sampleValues(j) - mult2;
  fprintf(fid, "%d %d %d %d %d %d %d %d %d %d\n", real(sampleValues(j)), imag(sampleValues(j)), real(sampleValues(j+8)), imag(sampleValues(j+8)), real(twiddleFactors(j)), imag(twiddleFactors(j)), real(result1), imag(result1), real(result2), imag(result2));
  fflush(fid);
endfor
fclose(fid);

% By: Denny Hermawanto
% Puslit Metrologi LIPI, INDONESIA
% Copyright 2015

fft_length = input('Enter FFT length:');

for mm = 0:1:(fft_length-1)
    theta = (-2*pi*mm*1/fft_length);

%   Twiddle factor equation
%   twiddle = exp(1i*theta);

%   Euler equation for complex exponential 
%   e^(j*theta) = cos(theta) + j(sin(theta)) 
    
    twiddle(mm+1) = cos(theta) + (1i*(sin(theta)));

    real_twiddle = real(twiddle);
    im_twiddle = imag(twiddle);
    
end;
save_real = real_twiddle;
save_im   = im_twiddle;
for mm = 1:1:(fft_length)
  bin_real = 0;
  bin_imag = 0;
  if (abs(real_twiddle(mm)) - 1 >= 0 || abs(im_twiddle(mm)) -1 >= 0)
    if (abs(real_twiddle(mm)) - 1 >= 0)
      real_twiddle_bin(mm) = 1;
      im_twiddle_bin(mm) = 0;
    else
      real_twiddle_bin(mm) = 0;
      im_twiddle_bin(mm) = 1;
     endif
  else
    for loop = 1:1:15
      bin_real =  bitshift(bin_real, 1);
      bin_imag = bitshift(bin_imag, 1);      
      real_twiddle(mm) = 2*abs(real_twiddle(mm));
      im_twiddle(mm)   = 2*abs(im_twiddle(mm));
      if(real_twiddle(mm) - 1 >= 0)
        bin_real = bin_real + 1;
        real_twiddle(mm) = real_twiddle(mm) - 1;
      endif
      if(im_twiddle(mm) - 1 >= 0)
        bin_imag = bin_imag + 1;
        im_twiddle(mm) = im_twiddle(mm) - 1;
      endif 
   end
    real_twiddle_bin(mm) = bin_real;
    im_twiddle_bin(mm)    = bin_imag;
  endif
end
invert = bitshift(1,16)-1;
fid = fopen("twidMemContents.txt", "w");
fprintf(fid,"process\nbegin\n");
fflush(fid);
for mm = 1:1:(fft_length)
  if(mm >= fft_length/2)
    im_print = im_twiddle_bin(mm);
  else 
    im_print = bitxor(im_twiddle_bin(mm), invert) + 1;
  endif

  real_print = real_twiddle_bin(mm);
  if(mm <= fft_length/4 || mm >= 3*fft_length/4)
    printvalue = bitshift(real_print,16) + im_print;
    fprintf(fid, "\tmemory(%d) <= to_signed(%d, data_width);\n", mm-1, printvalue);
    fflush(fid);
  else
    if (real_print != 0)
      real_print = bitxor(real_print, invert) + 1;
    endif
    printvalue = bitshift(real_print,16) + im_print;
    fprintf(fid, "\tmemory(%d) <= to_signed(%d, data_width);\n", mm-1, typecast(uint32(printvalue),'int32'));
    fflush(fid);
  endif
end
fprintf(fid, "\twait;\nend process;");
fflush(fid);
fclose(fid);

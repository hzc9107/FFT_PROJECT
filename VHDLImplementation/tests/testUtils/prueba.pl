use strict;
use warnings;

my $numberOfSamples = <STDIN>;
chomp $numberOfSamples;
open(my $fh, '>', 'memoryAContents.txt');
print $fh "process\nbegin\n";
for(my $sample = 0; $sample <  $numberOfSamples; $sample++){
  if(0 == $sample){
    print $fh "\tmemory($sample) <= to_signed(";
    print $fh 1<<25;
    print $fh ", data_width);\n";
  } else {
    print $fh "\tmemory($sample) <= (others=>\'0\');\n";
  }
}
print $fh "\twait;\nend process;";
close($fh);

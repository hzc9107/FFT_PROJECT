use strict;
use warnings;

my $numberOfSamples = <STDIN>;
chomp $numberOfSamples;
open(my $fh, '>', 'memoryAContents.txt');
for(my $sample = 0; $sample <  $numberOfSamples; $sample++){
  if(0 == $sample){
    print $fh 1<<25;
    print $fh "\n";
  } else {
    print $fh "0\n";
  }
}

close($fh);

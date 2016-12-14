#!/usr/bin/env perl

use strict;
use warnings;

my $num_args = $#ARGV + 1;
if ($num_args != 6) {
  print "\nUsage: sh.pl <bg> <fg> <size> <radius> <n> <time>\n";
  exit;
}

my $bg = $ARGV[0];
my $fg = $ARGV[1];
my $px = $ARGV[2] + 0;
my $ra = $ARGV[3] + 0;
my $n  = $ARGV[4] + 0;
my $ti = $ARGV[5] + 0;

my $center = $px / 2;
my $size = ($px + 1);
my $alphamul = 0.8;
#phase 1
for (my $i = 0; $i < $n; $i++) {

  my $file = sprintf "%03d-frame.png", $i;

  my $_p = ($i / ($n-1));
  my $p  = ($_p);
  my $pi = (1 - $_p);

  my $alpha = sprintf "%.3f", $p; # round to 3 decimals
  my $alphai = sprintf "%.3f", $pi; # round to 3 decimals

  my $radius = sprintf "%d", ($p * $ra);
  my $radiusi = sprintf "%d", ($pi * $ra);

  my $cmd = "convert";
  $cmd .= " -alpha on";
  $cmd .= " -size ";
  $cmd .= $size . "x" . $size;
  $cmd .= " 'xc:RGB(" . $bg . ")'";
  $cmd .= " -draw ";
  $cmd .= "\""; # open quote
  # c1
  $cmd .= " fill rgba(" . $fg . ", " . ($alphai * $alphamul) . ") circle " . $center . "," . $center;
  $cmd .= " " . $center . "," . $radius;
  #-----
  #c2
  $cmd .= " fill rgba(" . $fg . ", " . ($alpha * $alphamul) . ") circle " . $center . "," . $center;
  $cmd .= " " . $center . "," . $radiusi;
  #----
  $cmd .= "\""; # close quote
  $cmd .= " " . $file;

  print $i, ": \t\t", $radius . "," . ($alpha * $alphamul) . ";\t" . $radiusi . "," . $alphai . "\n";
  system($cmd);
}

# gif!
# convert -delay 20 -loop 0 *-frame.png loader.gif
my $imdelay = 0.01; # 1/100th of a second
print "making gif ... ";
system("convert -delay " . (($ti / $n) / $imdelay) . " -loop 0 *-frame.png loader.gif");
print "loader.gif\n";

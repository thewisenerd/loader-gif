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

# ease-in-out
# my $mX1 = 0.42;
# my $mY1 = 0.0;
# my $mX2 = 0.58;
# my $mY2 = 1.0;

# ease
#(0.25, 0.1, 0.25, 1.0)
my $mX1 = 0.25;
my $mY1 = 0.1;
my $mX2 = 0.25;
my $mY2 = 1.0;

sub A {
  my @list = @_;
  return (1.0 - 3.0 * $list[1] + 3.0 * $list[0]);
}

sub B {
  my @list = @_;
  return 3.0 * $list[1] - 6.0 * $list[0];
}

sub C {
  my @list = @_;
  return 3.0 * $list[0];
}

sub CalcBezier {
  my @list = @_;
  my $aT = $list[0];
  my $aA1 = $list[1];
  my $aA2 = $list[2];

  return ((A($aA1, $aA2)*$aT + B($aA1, $aA2))*$aT + C($aA1))*$aT;
}

sub GetSlope {
  my @list = @_;
  my $aT = $list[0];
  my $aA1 = $list[1];
  my $aA2 = $list[2];

  return 3.0 * A($aA1, $aA2)*$aT*$aT + 2.0 * B($aA1, $aA2) * $aT + C($aA1);
}

# (mX1, mY1, mX2, mY2)
# ($mX1, 0.0, $mX2, 1.0)
sub GetTForX {
  # Newton raphson iteration
  my @list = @_;
  my $aX = $list[0];

  my $aGuessT = $aX;
  for (my $i = 0; $i < 4; $i++) {
    my $currentSlope = GetSlope($aGuessT, $mX1, $mX2);
    if ($currentSlope == 0.0) {
      return $aGuessT;
    }
    my $currentX = CalcBezier($aGuessT, $mX1, $mX2) - $aX;
    $aGuessT -= $currentX / $currentSlope;
  }
  return $aGuessT;
}

sub get {
  my @list = @_;
  my $aX = $list[0];

  return CalcBezier(GetTForX($aX), $mY1, $mY2);
}

# ease-in-out : (0.42, 0.0, 0.58, 1.0)
for (my $i = 0; $i < $n; $i++) {

  my $file = sprintf "%03d-frame.png", $i;

  my $_p = ($i / ($n-1));
  my $p  = get($_p);
  my $pi = get(1 - $_p);

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

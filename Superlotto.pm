package Superlotto;

# @(#) NMG/2WM - $Id: Superlotto.pm,v 1.1.1.1 2023/02/09 23:49:35 user Exp $

use strict;
use warnings;
no strict "refs";
use Data::Dumper;

# Or on Windows: set PERL5LIB=.;Modules;C:/Users/user/xampp/cgi-bin/Module
# or for Cygwin / Linux: PERL5LIB=.:Modules:/cygdrive/c/Users/user/xampp/cgi-bin/Module

use lib ('.'); # 'Modules', 'C:/Users/user/xampp/cgi-bin/Modules');
use SuperlottoDB;

$!=0;
($^O =~ /cygwin/i) && die "Must run in Windows, to connect to the Database. Exiting...";

sub new
{
my $class=shift;
my $self=();
$self->{'dbc'}             =  new SuperlottoDB;
bless($self, $class);
return $self;
} # new

sub factor_num
{
my ($self, $n, $aref)=@_;
if(int($n) >= 1000)
  {
  my (@y) = $n =~ /(\d\d)(\d\d)/;
  push(@{$aref}, int($y[0]));
  push(@{$aref}, int($y[1]));
  push(@{$aref}, int($y[0]) + int($y[1]));
  }
else
  {
  push(@{$aref}, int($n));
  if(int($n) > 9)
    {
    my @arr=split('', $n);
    ($arr[$#arr] == 0) && pop(@arr);
    ($arr[0] == 0) && shift(@arr);
    my $s=0;
    foreach (@arr)
      {
      $s+=int($_);
      }
    push(@{$aref}, int($s));
    }
  }
} # factor_num

sub gen_factors
{
my ($self, $dt, $aref)=@_;
my ($Y, $m, $d)=split(/\-/, $dt);
my @n=();
$self->factor_num($m, \@n);
$self->factor_num($d, \@n);
$self->factor_num($Y, \@n);
my %N=map { $_ => 1 } @n; # make unique
(defined $N{0}) && delete $N{0};
@n=sort keys %N;
(defined $aref) ? push(@{$aref}, @n) : return \@n;
} # gen_factors

sub gen_nums
{
my ($self, $dt, $aref)=@_;
my @n=();
$self->gen_factors($dt, \@n);
(defined $aref) && push(@{$aref}, @n);
} # gen_nums

my @names=();

sub process_draw
{
my ($self, $href)=@_;

my @nums=();
$self->gen_nums($href->{'dd_date'}, \@nums);
# print "$href->{'dd_date'}\n";
# print Dumper \@nums;
if($#names == -1)
  {
  my @col_names=sort keys %{$href};
  @names=grep /ball_\d/, @col_names;
  }
my @balls=();
foreach my $n (@names)
  {
  push(@balls, $href->{$n});
  }
$href->{'pb'} ||= 0;
my $pb=$href->{'pb'};
$href->{'pp'} ||=0;
my $pp=($href->{'pp'} > 0) ? $href->{'pp'} : undef;
foreach my $n (@nums)
  {
  ($n == $pb) && print "PB: $n = $pb\n";
  ((defined $pp) && ($n == $pp)) && print "PP : $n = $pp\n";
  foreach (@balls)
    {
    if($_ == $n)
      {
      printf "Ball $_ matches $n\n";
      last;
      }
    }
  }
} # process_draw

#### opts functions

sub future_draw_date
{
my ($self, $fdate)=@_;
my @nums=();
$self->gen_nums($fdate, \@nums);
print "Suggested numbers for $fdate:\n";
print Dumper \@nums;
### get rows from DB
my @rows=();
$self->{'dbc'}->select_draw_re(\@rows, '%', 1);
my $href=();
FDAY:
foreach $href (@rows)
  {
  if($href->{'dd_date'} eq $fdate)
    {
    print "Previous draw numbers for $fdate:\n";
    print Dumper $href;
    last FDAY;
    }
  }
} # future_draw_date

sub get_draw
{
my ($self, $date)=@_;
my @nums=();
my @rows=();
$self->{'dbc'}->select_draw_re(\@rows, $date, 1);
my $href=();
if(@rows)
  {
  unshift(@rows, "Previous draw numbers for $date:\n");
  }
else
  {
  print STDERR "Previous draw date: $date, not found in database\n";
  }
return \@rows;
} # get_draw

sub get_draw_re
{
my ($self, $date_re)=@_;
my @nums=();
my @rows=();
$self->{'dbc'}->select_draw_re(\@rows, $date_re, 1);
my $href=();
foreach $href (@rows)
  {
  print "Day: $href->{'dd_day'}, Date: $href->{'dd_date'}:\n";
  # print Dumper $href;
  }
} # get_draw_re


sub process_all
{
my ($self)=@_;

my @rows=();
$self->{'dbc'}->select_all_rows(\@rows, 1);
my $href=();
foreach $href (@rows)
  {
  $self->process_draw($href);
  }
} # process_all

#### test_all_formulae.pl begin
 
use constant HIGH_BALL => 69;
use constant PB_HIGH_BALL => 26;

# Human Factor
my %hfs=( 'HF1' => 1, 'HF2' => 2);

our @FORMULA=();
our @formula=();
our %factors=();
our $val=0;
my $matches=0;
my $tot_dates=0;
my ($start_block, $end_block)=('', '');
my $rpt_fh;
my $base_fl='formula_rpt.txt';
my $rpt_fl= ($^O ne 'MSWin32') ? '/tmp/' : 'C:/cygwin64/tmp/';
$rpt_fl .= $base_fl;
my @ROWS=();

sub get_data
{
my ($self)=@_;
$self->{'dbc'}->select_all_rows(\@ROWS, 1);
$self->{'dbc'}->get_formulae($self->{'fdate'}, \@FORMULA);
} # get_data

sub gen_equation
{
my ($str_sref)=@_;
for(my $j=0; $j <= $#formula; $j++)
  {
  if($formula[$j] !~ /[a-hA-DHF]/)
    {
    $$str_sref .= " $formula[$j] ";
    }
  else
    {
    my $t=$formula[$j];
    my $v=(defined $factors{$t}) ? $factors{$t} : undef;
    ($t =~ /HF/) && ($v=$hfs{$t});
    (defined $v) ? ($$str_sref .= " $v ") : print STDERR "v not defined $j $t\n";
    }
  } # for j
} # gen_equation

sub eval_equation
{
my ($str_sref)=@_;
eval($$str_sref);
if($@)
  {
  printf STDERR "%s\n%s: f_array\n. *** STR: %s ***\n", $@, join(', ', @formula), $$str_sref;
  $val=undef;
  }
} # eval_equation

sub mk_factors_from_str
{
my ($self, $str)=@_;
%factors=();
my @arr=split(',', $str);
for(my $i=0; $i <= $#arr; $i++)
  {
  my $k=$arr[$i];
  $i++;
  my $v=$arr[$i];
  $factors{$k}=$v;
  }
} # mk_factors_from_str

sub main_process
{
my ($self)=@_;
my $href=();
my @ball_names=();
foreach $href (@ROWS)
  {
  ($#ball_names == -1) && (@ball_names=grep /^ball_\d/, sort keys %{$href});
  if(defined $href->{'dd_factors'})
    {
    $self->mk_factors_from_str($href->{'dd_factors'});
    $val=0;
    my $str=' $val = ';
    gen_equation(\$str);
    $str =~ s%/\s+0%/ 1%g;
    ($str eq ' $val = ') && next;
    eval_equation(\$str);
    $val = (defined $val) ? int($val) : 0;
    if($val)
      {
      my $pb=(defined($href->{'red_ball'})) ? $href->{'red_ball'} : 0;
      my $pp=(defined($href->{'power_play'})) ? $href->{'power_play'} : 0;
      my $mp=(defined($href->{'dd_mp'})) ? $href->{'dd_mp'} : undef;
      if($val == int($pb))
        {
        $matches++;
        printf $rpt_fh  "$href->{'dtype'}, $val matched PB $pb for draw : $href->{'dd_day'}, $href->{'dd_date'}\n";
        }
      my $fnd=0;
BN:
      foreach my $bn (@ball_names)
        {
        my $b=$href->{$bn};
        if(($b =~ /^\d+$/) && ($val =~ /^\d+$/))
          {
	  if(int($b) == $val)
	    {
	    $fnd=int($b);
	    last BN;
	    }
	  }
        else
          {
	  print "$bn either $b or $val is non-numeric\n";
	  }
        }
      if($fnd)
        {
        $matches++;
        printf $rpt_fh  "$href->{'dtype'} $val matched ball $fnd for draw : $href->{'dd_day'}, $href->{'dd_date'}\n";
        }
      } # if $val
    } # factors
  } # ROWS
} # main_process

sub get_tot_dates
{
my ($self)=@_;
my $tot=0;
my $href=();
foreach my $href (@ROWS)
  {
  ($href->{'dtype'} eq 'rd') && $tot++;
  }
return $tot;
} # get_tot_dates

sub check_rpt_file
{
my($self)=@_;
open(my $fh, '<', $rpt_fl) || die "Cannot open $rpt_fl for reading. Exiting...$!";
my @A=<$fh>;
close($fh);
open($fh, '>', $rpt_fl) || die "Cannot open $rpt_fl for writing. Exiting...$!";
my @a=();
for(my $i=0; $i <= $#A; $i++)
  {
  if($A[$i] =~ /$start_block/)
    {
    $i++;
    while($A[$i] !~ /$end_block/)
      {
      $i++;
      }
    $i++;
    }
  else
    {
    print $fh $A[$i];
    }
  }
close($fh);
} # check_rpt_file

sub block_handler
{
my ($self, $href)=@_;
$matches=0;
@formula=();
if(defined($href->{'f_formula'}) && (defined($href->{'f_id'})))
  {
  @formula=split(' ', $href->{'f_formula'});
  }
else
  {
  warn "formula or id not defined. Skipping...\n";
  return;
  }
my $mk_key=$href->{'f_id'};
$start_block="Begin:$mk_key";
$end_block="End:$mk_key";
printf $rpt_fh "$start_block\nProcessing $mk_key, formula=%s\n", join(' ', @formula);
$self->main_process();
if($matches)
  {
  my $prcnt=($matches / $tot_dates) * 100;
  printf $rpt_fh  qq^%d matches found\nFormula: %s\nPercentage of total date(%d): %4.2f %%\n^, $matches,
                                                                                               join(' ', @formula),
                                                                                               $tot_dates,
                                                                                               $prcnt;
  }
print $rpt_fh "$end_block\n";
} # block_handler

sub test_formula
{
my ($self, $opt)=@_;
$self->{'fdate'}=$self->{'fidx'}=undef;
if(defined($opt) && ($opt ne 'all'))
  {
  my ($fdate, $fidx)=split(',', $opt);
  $self->{'fdate'}=$fdate;
  (defined $fidx) && ($self->{'fidx'}=$fidx);
  }
else
  {
  $self->{'fdate'} = 'all';
  }
$self->get_data();
$tot_dates=$self->get_tot_dates();
open($rpt_fh, '>', $rpt_fl) || die "Cannot open $rpt_fl for appending. Exiting...$!";
my $href=();
my $fidx = (defined($self->{'fidx'})) ? $self->{'fidx'} : undef;
(defined $fidx) && ($href=$FORMULA[$fidx]);
if(scalar(keys %{$href}) != 0)
  {
  $self->block_handler($href);
  }
else
  {
  foreach $href (@FORMULA)
    {
    $self->block_handler($href);
    } # for fidx
  } # foreach $href
close($rpt_fh);
} # test_formula

#### test_all_formulae.pl end

1;

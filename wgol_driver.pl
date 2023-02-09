#!/usr/bin/perl

# @(#) NMG/2WM - $Id: wgol_driver.pl,v 1.1.1.1 2023/02/09 23:49:35 user Exp $
use strict;
use warnings;
use File::Basename qw(basename);

use Wrapper::GetoptLong;
use lib ('.');
use Superlotto;

# in the OPTS_CONFIG hash use $obj for func. The Wrapper constructor uses obj internally to the object
# passed to it. Command line options are saved in %opts (private). 
# But can be used in CONFIG hash as argument to a function, an example is the get_draw option, please see below.

($^O eq 'MSWin32') && ($ENV{'HOME'}='C:/cygwin64/home/user');

# opt_arg_eg is opt_arg_example
# help option will be add automatically by GetoptWrapper.pm

my %OPTS_CONFIG=(
   'process_all'      => {
      'desc'         => 'process all draw dates.',
      'func'         => '$obj->process_all()',
      'opt_arg_eg'   => '',
      'opt_arg_type' => '',
   },
   'load_formula'     => {
      'desc'         => "load formulae from ALL_F hash in file: formulae.pl",
      'func'         => q^$obj->{'dbc'}->load_formulae_to_db()^,
      'opt_arg_eg'   => '',
      'opt_arg_type' => '',
   },
   'get_draw'         => {
      'desc'         => "followed by date in YYYY-MM-DD format. To get the drawing result for that date.",
      'func'         => q^$obj->get_draw($opts{'get_draw'})^,
      'opt_arg_eg'   => '<YYYY-MM-DD>',
      'opt_arg_type' => 's',
   },
   'get_draw_re'      => {
      'desc'         => "followed by date regex, underscore is wild card in the database. Get dates that match regex.",
      'func'         => q^$obj->get_draw_re($opts{'get_draw_re'})^,
      'opt_arg_eg'   => '<20__-01-01>', 
      'opt_arg_type' => 's',
   },
   'future_draw_date' => {
      'desc'         => "followed by date in YYYY-MM-DD format, generate suggested numbers.",
      'func'         => q^$obj->future_draw_date($opts{'future_draw_date'})^,
      'opt_arg_eg'   => '<YYYY-MM-DD>', 
      'opt_arg_type' => 's',
   },
   'gen_factors'      => {
      'desc'         => "followed by date in YYYY-MM-DD format, generate factors hash ref.",
      'func'         => q^$obj->{'dbc'}->mk_factors_str($opts{'gen_factors'})^,
      'opt_arg_eg'   => '<YYYY-MM-DD>', 
      'opt_arg_type' => 's',
   },
   'add_month'        => {
      'desc'         => "followed by <file-name(s)> in MonYYYY.txt format, e.g. Jan2023.txt  to load into the database.",
      'func'         => q^$obj->{'dbc'}->add_month_to_db($opts{'add_month'})^,
      'opt_arg_eg'   => '<MonYYYY.txt>', 
      'opt_arg_type' => 's{,}',
   },
);

our $sl=new Superlotto;
my $wgol=new Wrapper::GetoptLong(\%OPTS_CONFIG, $sl);
$wgol->run_getopt();
my $rc=$wgol->execute_opt();
if(ref($rc))
  {
  use Data::Dumper;
  print Dumper $rc;
  }
else
  {
  print $rc;
  }

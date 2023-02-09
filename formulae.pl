#!/usr/bin/perl

# @(#) NMG/2WM - $Id: formulae.pl,v 1.1.1.1 2023/02/09 23:49:35 user Exp $
use strict;
use warnings;

use Storable qw(store);
use Data::Dumper;

our $all_f_store='/tmp/all_f.store';

our %ALL_F=(
 'Saturday' => {
   '01-01-2022' => [
      [ qw^A + B + g + h^ ],
      [ qw^( A + C ) * ( e + f + g + h )^ ],
      [ qw^C + D - a - b - c - d - HF1^ ],
      [ qw^( A + B ) * D + g + h^ ],
      [ qw^( A + B ) * D + e + f + g + h^ ],
      [ qw^e + f + g + h + B^ ],
   ],
   '01-08-2022' => [ # powerplay = 10
      [ qw^( A + B ) * h + h^ ],
      [ qw^( A + B ) * h + h + A^ ],
      [ qw^B * h + C^],
      [ qw^( A + B ) * h + C + D^ ],
      [ qw^( A + B ) * h + C + D + e + f + g + h - A^ ],
      [ qw^A + B + g + h^ ],
   ],
   '01-15-2022' => [
      [ qw^d - c - A^ ],
      [ qw^B + A + h^ ],
      [ qw^C + D - d^ ],
      [ qw^C + D + d + g + h^ ],
      [ qw^C + D + B + h^ ],
      [ qw^B - A - HF1^ ],
   ], 
   '10-29-2022' => [
      [ qw^B - A^ ],
      [ qw^B + HF2^ ],
      # BIN(A) + B^,
      [ qw^A + B + HF1^ ],
      [ qw^A + B + HF1 + e + f + g + h^ ],
      [ qw^e * D + B - A - ( e + f + g + h )^ ],
      [ qw^B - A + g + h^ ],
   ],
 },
 'Monday'    => {
   '01-03-2022' => [
      [ qw^B - A^ ],
      [ qw^( g + h ) * B + A^ ],
      [ qw^( B - A ) * ( g + h ) * ( g + h )^ ],
      [ qw^( B - A ) * ( g + h ) * ( g + h ) + A^ ],
      [ qw^( D * B ) - C + B - A^ ],
      [ qw^B * ( e + f * g + h ) + g + h^ ],
   ],
   '01-10-2022' => [
      [ qw^B + g + h^ ],
      [ qw^B + A + e + f + g + h^ ],
      [ qw^B + A + e + f + g + h - HF1^ ],
      [ qw^D + B - A - g - h^ ],
      [ qw^D - HF1^ ],
      [ qw^B - A^ ],
   ],
   '01-17-2022' => [
      [ qw^c + d + A^ ],
      [ qw^C + D + c + d - g - h^ ],
      [ qw^h * B^ ],
      [ qw^( h * B ) + A^ ],
      [ qw^C + D + B + e + f + g + h^ ],
      [ qw^A + B + g + h^ ],
   ],
   '01-31-2022' => [
      [ qw^c + d + e + f + g + h^ ],
      [ qw^( B - A ) / h^ ],
      [ qw^B + C^ ],
      [ qw^B * h - A^ ],
      [ qw^B + C + D - f - h^ ],
      [ qw^( B - A ) / h - HF1^ ],
   ],
 },
 'Wednesday'  => {
   '01-05-2022' => [
      [ qw^A + B^ ],
      [ qw^C - B - A^ ],
      [ qw^C + B^ ],
      [ qw^A + B + D + d^ ],
      [ qw^C + D + B - A^ ],
      [ qw^D - B^ ],
   ],
   '01-12-2022' => [
      [ qw^A * B^ ],
      [ qw^B + e + f + g + h + c + d^ ],
      [ qw^B + e + f + g + h + c + d + A^ ],
      [ qw^C + D - B^ ],
      [ qw^C + D - B + c + d^ ],
      [ qw^B * d^ ],
   ], 
   '02-16-2022' => [
      [ qw^A + B + g + h^ ],
      [ qw^( B - HF1 ) * A^ ],
      [ qw^( g + h + B ) * A^ ],
      [ qw^( c + d ) * d^ ],
      [ qw^( b + c ) * B^ ],
      [ qw^( e + f + g + h ) * d * A^ ],
      [ qw^( c + d ) * A + A^ ],
   ],
   '06-29-2022' => [
      [ qw^A + c^ ],
      [ qw^A + B + e + f + g + h - HF1^ ],
      [ qw^C + D + A + HF1^ ], # or
      [ qw^e + f + B^ ],
      [ qw^C + D + A + c + d - HF1^ ],
      [ qw^C + D + B + A - HF2^ ],
      [ qw^( d - c ) * h^ ],
   ],
 },
);


store(\%ALL_F, $all_f_store);

1;

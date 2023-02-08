package SuperlottoDB;

# @(#) NMG/2WM - $Id: SuperlottoDB.pm,v 1.4 2023/01/24 19:50:15 user Exp $

use strict;
use warnings;
use DBI;

use lib ('.');

sub new
{
my $class=shift;
my $db='superlotto';
(@_) && ($db=shift);

my $self=();

$self->{'source'}          = "DBI:mysql:$db:127.0.0.1";
$self->{'username'}        = 'root';
$self->{'password'}        = '';
bless($self, $class);
$self->{'dbc'}             = DBI->connect($self->{'source'}, $self->{'username'}, $self->{'password'})
                             or die "Unable to connect to mysql: " . $DBI::errstr;
return $self;
} # new

sub formula_exists
{
my($self, $dt)=@_; # dt format : YYYY-MM-DD
$dt =~ s/['"]//g;
my $rc=0;
my $dd_id=$self->date_exists($dt);
if($dd_id != 0)
  {
  my $sql_stmnt = sprintf(q^SELECT fk_dd_id FROM tbl_formula WHERE  fk_dd_id = %d^, $dd_id);
  my $sql = $self->{'dbc'}->prepare($sql_stmnt);
  my $out = $sql->execute() or die "Unable to execute sql: $sql_stmnt.\n" . $DBI::errstr;
  my $fk_dd_id=$sql->fetchrow_array();
  $fk_dd_id ||=0;
  $rc=$fk_dd_id;
  }
return $rc;
} # formula_exists

sub date_exists
{
my($self, $dt)=@_; # dt format : YYYY-MM-DD
$dt =~ s/['"]//g;
my $rc=0;
my $sql_stmnt = sprintf(q^SELECT dd_id FROM tbl_day_dt WHERE  dd_date = '%s'^, $dt);
my $sql = $self->{'dbc'}->prepare($sql_stmnt);
my $out = $sql->execute() or die "Unable to execute sql: $sql_stmnt.\n" . $DBI::errstr;
my $dd_id=$sql->fetchrow_array();
$dd_id ||=0;
# my $cnt=$sql->rows;
$rc=$dd_id;
return $rc;
} # date_exists


sub insert_day_dt_row
{
my($self, $day, $dt)=@_;
$dt =~ s/['"]//g;
my $dd_id=$self->date_exists($dt);
if($dd_id == 0)
  {
  my $mp=$self->get_moonphase($dt);
  my $factors_str=$self->factor_date($dt); 
  my $sql_stmnt=sprintf(q^
   INSERT INTO tbl_day_dt(dd_day, dd_date, dd_mp, dd_factors)
   VALUES ('%s', '%s', %d, '%s')
^, $day, $dt, $mp, $factors_str);
  # print "$sql_stmnt\n";
  my $sql = $self->{'dbc'}->prepare($sql_stmnt);
  my $out = $sql->execute() or die "Unable to execute sql: $sql_stmnt.\n" . $DBI::errstr;
  $dd_id=$self->date_exists($dt);
  }
return $dd_id;
} # insert_day_dt_row

sub insert_draw_row
{
my($self, $dd_id, $href)=@_;
my $me=(caller(0))[3];
my $parent=(caller(1))[3] || 'no caller parent';
# logit("%s called from %s\n", (caller(0))[3], (caller(1))[3]);
# print "$me called from $parent\n";

my $sql_stmnt=sprintf(q^
INSERT INTO tbl_draw(fk_dd_id, dtype, ball_1, ball_2, ball_3, ball_4, ball_5, red_ball, multiplier)
               VALUES ( %d, '%s', %d, %d, %d, %d, %d, %d, %d
)
^, $dd_id, $href->{'type'}, $href->{'balls'}[0], $href->{'balls'}[1], $href->{'balls'}[2], $href->{'balls'}[3], $href->{'balls'}[4],
                  $href->{'pb'}, $href->{'pp'});

# print "$sql_stmnt\n";
my $sql = $self->{'dbc'}->prepare($sql_stmnt);
my $out = $sql->execute() or die "Unable to execute sql: $sql_stmnt.\n" . $DBI::errstr;
} # insert_draw_row

sub insert_formula_row
{
my($self, $dt, $formula_str)=@_;
my $dd_id=$self->date_exists($dt);
if($dd_id != 0)
  {
  my $sql_stmnt=sprintf(q^
   INSERT INTO tbl_formula(fk_dd_id, f_formula)
   VALUES (%d, '%s')
^, $dd_id, $formula_str);
  # print "$sql_stmnt\n";
  my $sql = $self->{'dbc'}->prepare($sql_stmnt);
  my $out = $sql->execute() or die "Unable to execute sql: $sql_stmnt.\n" . $DBI::errstr;
  $dd_id=$self->date_exists($dt);
  }
else
  {
  print "dd_id not found for date: $dt, skipping...\n";
  }
} # insert_formula_row

sub get_formulae
{
my ($self, $fdate, $aref)=@_;
my $sql_stmnt='SELECT f_id, f_formula FROM tbl_formula';
my @arr=();
my $id_found=0;
my $fk_dd_id=undef;

if($fdate ne 'all')
  {
  $fdate =~ s/['"]//g;
  $fk_dd_id=$self->formula_exists($fdate);
  ($fk_dd_id != 0) && ($sql_stmnt .= " WHERE fk_dd_id = $fk_dd_id ");
  }
$sql_stmnt .= q^
     GROUP BY f_id, f_formula
     ORDER BY f_id, f_formula
^;
 
if(!defined($fk_dd_id) || ($fk_dd_id > 0))
  {
  #  print "$sql_stmnt\n";
  my $sql = $self->{'dbc'}->prepare($sql_stmnt);
  my $out = $sql->execute() or die "Unable to execute sql: $sql_stmnt.\n" . $DBI::errstr;
  my $href=();
  while (($href->{'f_id'}, $href->{'f_formula'}) = $sql->fetchrow_array())
    {
    push(@arr, $href);
    $href=();
    }
  (defined($aref)) && push(@{$aref}, @arr);
  }
else
  {
  $self->{'fdate'} ||='';
  print STDERR "No formula was found for date : $self->{'fdate'}, in formula table, skipping...\n";
  }
} # get_formulae

sub get_factors
{
my ($self, $dt, $href)=@_;
my  $dd_id=$self->date_exists($dt);
my $factors_str='';
my %h=();
if($dd_id != 0)
  {
  my $sql_stmnt=qq^
   SELECT dd_factors FROM tbl_day_dt
   WHERE dd_id = $dd_id
^;
  # print "$sql_stmnt\n";
  my $sql = $self->{'dbc'}->prepare($sql_stmnt);
  my $out = $sql->execute() or die "Unable to execute sql: $sql_stmnt.\n" . $DBI::errstr;
  ($factors_str) = $sql->fetchrow_array();
  if($factors_str)
    {
    $factors_str =~ tr/\x0A-\x7f//cd;
    $factors_str =~ s/\r//;
    # print "$factors_str\n";
    # $factors_str =~ s/,/ /g;
    my (@a)=split(/,/, $factors_str);
    while(@a)
      {
      my $ch=shift(@a);
      my $val=shift(@a);
      $h{$ch}=$val;
      }
    (defined($href)) && (%{$href}=%h);
    }
  }
else
  {
  print "dd_id not found for date: $dt, skipping...\n";
  }
return \%h;
} # get_factors


sub select_all_rows
{
my ($self, $aref, $with_factors)=@_;
my $sql_stmnt='';
my @arr=();
$self->select_draw_re(\@arr, 'all', $with_factors);
(defined($aref)) && push(@{$aref}, @arr);
} # select_all_rows

sub select_draw_re
{
my($self, $aref, $dt_re, $with_factors)=@_;
my $sql_stmnt='';
(lc($dt_re) eq 'all') && ($dt_re='%');
if(!defined($with_factors))
  {
  $sql_stmnt = sprintf(q^SELECT dd_day, dd_date, dd_mp, dtype, ball_1, ball_2, ball_3, ball_4, ball_5, red_ball, multiplier
FROM tbl_day_dt dd
INNER JOIN tbl_draw d
ON dd.dd_id = d.fk_dd_id
WHERE dd_date LIKE '%s'
GROUP BY dd.dd_day, dd.dd_date, d.dtype
ORDER BY dd.dd_date, dd.dd_day, d.dtype
^, $dt_re);
  }
else
  {
  $sql_stmnt = sprintf(q^SELECT distinct dd_day, dd_date, dd_mp, dd_factors, dtype, ball_1, ball_2, ball_3, ball_4, ball_5, red_ball, multiplier
FROM tbl_day_dt dd
INNER JOIN tbl_draw d
ON dd.dd_id = d.fk_dd_id
WHERE dd_date LIKE '%s'
GROUP BY dd.dd_day, dd.dd_date, d.dtype
ORDER BY dd.dd_date, dd.dd_day, d.dtype
^, $dt_re);
  }

# print $sql_stmnt, "\n";

my $sql = $self->{'dbc'}->prepare($sql_stmnt);
my $out = $sql->execute() or die "Unable to execute sql: " . $sql_stmnt . $DBI::errstr;
my @arr=();
my $href=();

if(!defined($with_factors))
  {
  while (($href->{'dd_day'}, $href->{'dd_date'}, $href->{'dd_mp'}, $href->{'dtype'}, $href->{'ball_1'}, $href->{'ball_2'},
          $href->{'ball_3'}, $href->{'ball_4'}, $href->{'ball_5'}, $href->{'red_ball'},
	  $href->{'multiplier'}) = $sql->fetchrow_array())
    {
    push(@arr, $href);
    $href=();
    }
  }
else
  {
  while (($href->{'dd_day'}, $href->{'dd_date'}, $href->{'dd_mp'}, $href->{'dd_factors'}, $href->{'dtype'}, $href->{'ball_1'},
          $href->{'ball_2'}, $href->{'ball_3'}, $href->{'ball_4'}, $href->{'ball_5'}, $href->{'red_ball'},
	  $href->{'multiplier'}) = $sql->fetchrow_array())
    {
    push(@arr, $href);
    $href=();
    }
  } # else
(defined($aref)) && push(@{$aref}, @arr);
} # select_draw_re

#### from select.pl

sub factor_date
{
my ($self, $dt, $day, $href)=@_;
my ($Y, $m, $d)=split(/-/, $dt);
my %h=();
($h{'a'}, $h{'b'})=split('', $m);
($h{'c'}, $h{'d'})=split('', $d);
($h{'e'}, $h{'f'}, $h{'g'}, $h{'h'})=split('', $Y);
 $h{'A'}=int($m);
 $h{'B'}=int($d);
($h{'C'}, $h{'D'}) = $Y =~ /(\d\d)(\d\d)/;
my $str='';
foreach my $ch (sort keys %h)
  {
  $str .= "$ch,$h{$ch},";
  }
$str =~ s/,$//;
return $str;
} # factor_date

sub mk_factors_str
{
my ($self, $dt)=@_;
my $str='';
# Check if date is in DB format YYYY-MM-DD
($dt =~ /^20??/) && ($str=$self->factor_date($dt, undef, undef));
return $str;
} # mk_factors_str


#### end select.pl

#### from moonphase.pl

use DateTime;
use DateTime::Format::ISO8601;
use DateTime::TimeZone;
use Try::Tiny;
use Astro::MoonPhase;

use constant NEW_MOON   => 0;
use constant FIRST_QRTR => 1;
use constant FULL_MOON  => 2;
use constant LAST_QRTR  => 3;
my $event=
    {
    'name' => 'Next PB Drawing',
    'date' => '',
    'time' => '10:59:00',
    'timezone' => 'America/Havana',
    "location" => {lon=>-84.555534, lat=>42.732536}
    # Lansing MI: 42.732536, -84.555534.
    };

sub mp_process_event
{
my($self, $event, $href)=@_;
$href->{'epoch'} = $self->mp_parse_event($event);
($href->{'MoonPhase'}, $href->{'MoonIllum'}, $href->{'MoonAge'}, $href->{'MoonDist'}, $href->{'MoonAng'},
     $href->{'SunDist'}, $href->{'SunAng'}) = phase($href->{'epoch'});
$href->{'MoonPhase'} = sprintf('%4.2f', $href->{'MoonPhase'});
} # mp_process_event

sub mp_parse_event
{
my ($self, $event)=@_;
(! exists $event->{'date'} ) && die "date field is missing from event.";
my $datestr = $event->{'date'};
my $timestr = $event->{'time'};
my $isostr = $datestr . 'T' . $timestr;
my $dt = DateTime::Format::ISO8601->parse_datetime($isostr);
$event->{'datetime'} = $dt;
my $tzstr = $event->{'timezone'};
$dt->set_time_zone($tzstr);
$event->{'_is_parsed'} = 1;
$event->{'epoch'} = $dt->epoch;
return $event->{'epoch'}
} # mp_parse_event

sub get_moonphase
{
my ($self, $date)=@_;
my %h=();
my $mp=NEW_MOON;
# check for valid date format - YYYY-MM-DD, otherwise return 0 (new moon)
if($date =~ /^20??/)
  {
  $event->{'date'}=$date;
  $self->mp_process_event($event, \%h);

  if(($h{'MoonPhase'} >= '0.25') && ($h{'MoonPhase'} < '0.50')) { $mp=FIRST_QRTR; }
  elsif(($h{'MoonPhase'} >= '0.50') && ($h{'MoonPhase'} < '0.75')) { $mp=FULL_MOON; }
  elsif($h{'MoonPhase'} >= '0.75') { $mp=LAST_QRTR; }
  }
return $mp;
}  # get_moonphase
#### end moonphase.pl
#### from populate_db

sub add_month_to_db
{
my($self, $fl)=@_;
if(-f $fl)
  {
  open(my $fh, '<', $fl) || die "Cannot open $fl for reading. Exiting...$!";
  # Saturday  12-03-2022 06 13 33 36 37 07 4x Double Play 04 10 23 43 64 03
  while(<$fh>)
  {
    chomp();
    my @a=split(' ', $_);
    my $day=shift(@a);
    my $date=shift(@a);
    my ($m, $d, $Y)=split(/-/, $date);
    my $dt="$Y-$m-$d";
    if($dt eq '0000-00-00')
      {
      warn "$date / $dt not a valid database date format. Skipping...";
      next;
      }
    my $id=$self->{'dbc'}->date_exists($dt);
    warn "Checked if $dt exists, $id";
    if($id == 0)
      {
      # 2 11 22 35 60 23 2x Double Play 20 34 37 57 67 26
      $id=$self->{'dbc'}->insert_day_dt_row($day, $dt);
  
      if($id != 0)
        {
        my $href=();
        for(my $i=0; $i <= 4; $i++)
          {
          push(@{$href->{'balls'}}, shift(@a));
          }
        $href->{'pb'}=shift(@a);
        $href->{'pp'}=shift(@a);
        $href->{'type'} ='rd';
        $href->{'pp'} ||= 0;
        $href->{'pp'} =~ s/x//;
        $self->{'dbc'}->insert_draw_row($id, $href);
        shift(@a); # Double 
        shift(@a); # Play 
        $href=();
        $href->{'type'} ='dp';
        $href->{'pp'} = 0;
        for(my $i=0; $i <= 4; $i++)
          {
          push(@{$href->{'balls'}}, shift(@a));
          }
        $href->{'pb'}=shift(@a);
        $self->{'dbc'}->insert_draw_row($id, $href);
        } # id != 0
      } # id == 0
    } # while
  close($fh);
  }
else
  {
  warn "$fl file not found. Exiting...";
  }
} # add_month_to_db
#### end populate_db

#### from load_formulae_db.pl
our %ALL_F;


sub load_formulae_to_db
{
my ($self)=@_;
require 'formulae.pl';

foreach my $day (sort keys %ALL_F)
  {
  foreach my $date (sort keys %{$ALL_F{$day}})
    {
    my $dt=$date;
    if($date =~ /20??$/)
      {
      my ($m, $d, $Y)=split(/-/, $date);
      $dt="$Y-$m-$d";
      }
    elsif($date =~ /^20\d\d/)
      {
      my ($Y, $m, $d)=split(/-/, $date);
      $date="$m-$d-$Y";
      }
    my $dd_id=$self->formula_exists($dt);
    if(!$dd_id)
      {
      my @formula=@{$ALL_F{$day}{$date}};
      foreach my $f (@formula)
        {
        my $fstr=join(' ', @{$f});
        $self->insert_formula_row($dt, $fstr);
        }
      }
    }
  }
} # load_formulae_to_db
#### end load_formulae_db.pl

1;

# WGOLDemo
A demo app (SuperLotto) for the Wrapper::GetoptLong Perl module.
Requires a database, mySQL or MariaDB. Sql file supplied in the repository under the SQL subdiectory, will create and populate the database.

How to Install/run :
We will assume you have MySQL / MariaDB server and client installed.
Please, note : the SuperLottoDB.pm has the server, user and password hardcoded, you might have to change some of those:
  DBServer: 127.0.0.1  (or you can use localhost if not running on Windows - using Strawberry Perl).
  DBuser:  root
  Password: '' (not set)

We will assume everything is in the WGOLDemo folder/directory either by using the GitHub web link, from a browser, or the command line git utility:

      Web link is : https://github.com/ngabriel8/WGOLDemo
    Or the command line( in a terminal, or Command Prompt - on Windows)
      git clone https://github.com/ngabriel8/WGOLDemo.git

# DB section

cd SQL
gzip -d superlotto_db.sql.gz

mysql < superlotto_db.sql

Or if you have db_user and password, set:

mysql -u db_user -p  (will prompt for password)
# Once you're in the mysql prompt:
source suplerlotto_db.sql
quit


#  Run
The driver script is wgol_driver.pl
If on Mac/\*nix systems : make sure the exec bit is on : chmod 0755 wgol_drive.pl, 
    or if you want to be mean : 0555 - just to be sure nobody messes with the code.
The shbang line (#! - the first line) is set to /usr/bin/perl - You might have to change that to run it as : ./wgol_drive.pl

OR

perl  wgol_driver.pl

In either case, this will show the help message with available options - same as running it as:
perl wgol_driver.pl  --help
Which is the whole point of the module, since the help option and the usage message is displayed, is a freebie , auto generated by the module .


# **A Demo for A Perl Module**


## WGOLDemo

* A demo app (SuperLotto) for the Wrapper::GetoptLong Perl module.
* Requires a database, mySQL or MariaDB.
* A file supplied in the repository under the SQL sub-directory, will create and populate the database.
*  (SQL - Structured Query Language)


## Helpful hints:

* XAMPP is available for most platforms. A bundle that includes:
*  Apache (web server)
*  MariaDB (a database server/client)
*  FileZilla (a file server)
*  Mercury (mail server)
*  Tomcat (aka Catalina) - for serving Java/JSP on Apache (the Web).
*  As well as perl and php.
*  As and added bonus, phpMyAdmin is included to manage the database from a browser
*  For non-Windows platform, put '#!/usr/bin/perl' or '#!env perl' as the first line
*   of your script if you want to use the system Perl. For Windows using Strawberry Perl
*   is recommended strongly, because installing modules is much easier - since it has its own compilers and make, and cpanm.bat works:
*   #!C:/Strawberry/perl/bin/perl
*   assuming Strawberry is installed in the root directory of Windows.
*  Please note, you can also use the following form , for multi-platforms, works on Cygwin, Windows and Linux (Mint):
*  #!perl
      eval 'exec perl -wS $0 ${1+"$@"}'
               if $running_under_some_shell;
*  Assumes there is at least one Perl excutable to be found in the PATH/path variable.

## Assumptions:
* You have perl installed
* The Wrapper::GetoptLong module installed, please see WGOL hint below.
* You have MySQL / MariaDB server and client installed, already.
* Everything is in the WGOLDemo folder/directory, and we are working from there.

### WGOL hint:
* Requires make utility
* If you have cpanm installed, it is simple: 
* `cpanm Wrapper::GetoptLong`
* Any errors will be in build.log ($HOME/.cpanm/work/(tmp-build-dir-name)/build.log
* To uninstall:
* `cpanm -U Wrapper::GetoptLong`
* Otherwise, download the tar.gz file from CPAN
* `tar xzf Wrapper-GetoptLong-0.01.tar.gz
* `cd Wrapper-GetoptLong-0.01`
* `perl Makefile.PL` - this will genearate a Makefile
* make && make test && make install

## How to Install/run:

* Please, note : the SuperLottoDB.pm has the DB server name/IP,  user and password hardcoded, you might have to change some of those:
*  DB Server: 127.0.0.1  (or you can use localhost if not running on Windows - using Strawberry Perl).
*  DB User:  root
*  DB Password: '' (or NULL/undef - not set)


### Install 
*  By using the GitHub web link, from a browser,
*   [Link to GitHub](https://github.com/ngabriel8/WGOLDemo)
*  Or the command line git utility - On the command line(in a terminal, or Command Prompt - on Windows)
*   git clone <https://github.com/ngabriel8/WGOLDemo.git>


###  DB section
```sh
* cd SQL
* gzip -d superlotto_db.sql.gz
* mysql < superlotto_db.sql

# Or if you have db_user and password, set:
* mysql -u db_user -p
* # (will prompt for password)
* # Once you're in the mysql prompt:
* source suplerlotto_db.sql
* quit
```

## Running the driver (script)

* The driver script is wgol_driver.pl
* If on Mac and \*nix systems : make sure the exec bit is on :
*   chmod 0755 wgol_drive.pl
* Or if you want to be mean, 0555 - just to be sure nobody messes with the code.
*   The shbang line (#! - the first line) is set to /usr/bin/perl - You might have to change that to run it as :
`./wgol_drive.pl`
* Or (this should work on all systems)
`perl  wgol_driver.pl`
* In either case, this will show the help message with available options - same as running it as:
`perl wgol_driver.pl  --help`


##### Step 1 is a  Success!
*  The help option, the usage message it displays and the function **print\_usage\_and\_die**
*  are all freebies, auto generated by the module.
#### Step 2 is when run with an option,
* The module will call the function associated with the option
*  from the config hash (associative array)
*  defined in the driver script:  wgol_driver.pl

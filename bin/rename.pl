#!/usr/bin/perl -w
#
#  This script was developed by Robin Barker (Robin.Barker@npl.co.uk),
#  from Larry Wall's original script eg/rename from the perl source.
#
#  This script is free software; you can redistribute it and/or modify it
#  under the same terms as Perl itself.
#
# Larry(?)'s RCS header:
#  RCSfile: rename,v   Revision: 4.1   Date: 92/08/07 17:20:30 
#
# $RCSfile: rename,v $$Revision: 1.5 $$Date: 1998/12/18 16:16:31 $
#
# $Log: rename,v $
# Revision 1.5  1998/12/18 16:16:31  rmb1
# moved to perl/source
# changed man documentation to POD
#
# Revision 1.4  1997/02/27  17:19:26  rmb1
# corrected usage string
#
# Revision 1.3  1997/02/27  16:39:07  rmb1
# added -v
#
# Revision 1.2  1997/02/27  16:15:40  rmb1
# *** empty log message ***
#
# Revision 1.1  1997/02/27  15:48:51  rmb1
# Initial revision
#
 
use strict;
 
use Getopt::Long;
Getopt::Long::Configure('bundling');
 
my ($verbose, $no_act, $force, $op);
 
die "Usage: rename [-v] [-n] [-f] perlexpr [filenames]\n"
    unless GetOptions(
	'v|verbose' => \$verbose,
	'n|no-act'  => \$no_act,
	'f|force'   => \$force,
    ) and $op = shift;
 
$verbose++ if $no_act;
 
if (!@ARGV) {
    print "reading filenames from STDIN\n" if $verbose;
    @ARGV = <STDIN>;
    chop(@ARGV);
}
 
for (@ARGV) {
    my $was = $_;
    eval $op;
    die $@ if $@;
    next if $was eq $_; # ignore quietly
    if (-e $_ and !$force)
    {
	warn  "$was not renamed: $_ already exists\n";
    }
    elsif ($no_act or rename $was, $_)
    {
	print "$was renamed as $_\n" if $verbose;
    }
    else
    {
	warn  "Can't rename $was $_: $!\n";
    }
}

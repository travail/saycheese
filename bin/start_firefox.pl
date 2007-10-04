#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib '/home/public/cgi/lib';
use SayCheese;

my $config = SayCheese->config;
$ENV{DISPLAY} = $config->{DISPLAY};
my $cmd = '/usr/lib/firefox-1.5.0.10/firefox-bin';
my $r   = system $cmd;
warn "Execute command $cmd.\n";
die "$cmd return $r.\n\n" if $cmd;

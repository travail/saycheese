#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib '/home/public/cgi/lib';
use SayCheese::Utils qw/ saycheese_config /;

my $config = saycheese_config();
$ENV{DISPLAY} = $config->{DISPLAY};
my $cmd = 'firefox';
my $r   = system $cmd;
warn "Execute command $cmd.\n";
die "$cmd return $r.\n\n" if $r;

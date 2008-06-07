#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/ $Bin /;
use lib "$Bin/../lib";
use SayCheese::ConfigLoader;

my $config = SayCheese::ConfigLoader->new->config;
$ENV{DISPLAY} = $config->{DISPLAY};
my $cmd = 'firefox';
my $r   = system $cmd;
warn "Execute command $cmd.\n";
die "$cmd return $r.\n\n" if $r;

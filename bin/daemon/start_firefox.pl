#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

warn Dumper( \%ENV );
my $cmd = 'firefox';
my $r   = system $cmd;
warn "Execute command $cmd.\n";
die "$cmd return $r.\n\n" if $r;

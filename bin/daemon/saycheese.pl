#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw//;
use lib "$FindBin::Bin/../lib";
use SayCheese::ConfigLoader;
use SayCheese::Gearman::Worker;

my $worker = SayCheese::Gearman::Worker->new(worker_class => 'SayCheese');
$worker->work while 1;

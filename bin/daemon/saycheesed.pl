#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw//;
use lib "$FindBin::Bin/../../lib";
use Getopt::Long;
use Pod::Usage;
use SayCheese::ConfigLoader;
use SayCheese::Gearman::Worker;

my $debug = '';
my $help  = '';
pod2usage(1) if $help;
Getopt::Long::Configure('bundling');
GetOptions(
    'd|debug' => \$debug,
    'h|help'  => \$help,
);

my $worker = SayCheese::Gearman::Worker->new(worker_class => 'SayCheese');
$worker->work while 1;

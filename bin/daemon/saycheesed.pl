#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw();
use lib "$FindBin::Bin/../../lib";
use SayCheese::CLI::Daemon::SayCheese;

SayCheese::CLI::Daemon::SayCheese->new_with_options->run;

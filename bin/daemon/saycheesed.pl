#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw();
use lib "$FindBin::Bin/../../lib";
use SayCheese::CLI::SayCheese;

SayCheese::CLI::SayCheese->new_with_options->run;

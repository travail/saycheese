#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../../lib";
use SayCheese::CLI::Queue::SayCheese::Insert;

SayCheese::CLI::Queue::SayCheese::Insert->new_with_options->run;

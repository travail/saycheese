#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../../lib";
use SayCheese::CLI::Queue::SayCheese::Delete;

SayCheese::CLI::Queue::SayCheese::Delete->new_with_options->run;

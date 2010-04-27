#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../../lib";
use SayCheese::CLI::Queue::SayCheese::Reenqueue

SayCheese::CLI::Queue::SayCheese::Reenqueue->new_with_options->run;

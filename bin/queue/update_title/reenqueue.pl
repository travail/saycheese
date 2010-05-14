#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../../lib";
use SayCheese::CLI::Queue::Fetch::Title::Reenqueue;

SayCheese::CLI::Queue::Fetch::Title::Reenqueue->new_with_options->run;

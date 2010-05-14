#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../../lib";
use SayCheese::CLI::Queue::Fetch::Title::Enqueue;

SayCheese::CLI::Queue::Fetch::Title::Enqueue->new_with_options->run;

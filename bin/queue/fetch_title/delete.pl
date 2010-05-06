#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../../lib";
use SayCheese::CLI::Queue::Fetch::Title::Delete;

SayCheese::CLI::Queue::Fetch::Title::Delete->new_with_options->run;

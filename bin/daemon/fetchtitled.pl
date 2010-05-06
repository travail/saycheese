#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../lib";
use SayCheese::CLI::Daemon::Fetch::Title;

SayCheese::CLI::Daemon::Fetch::Title->new_with_options->run;

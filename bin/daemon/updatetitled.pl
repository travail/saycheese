#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../lib";
use SayCheese::CLI::Daemon::Update::Title;

SayCheese::CLI::Daemon::Update::Title->new_with_options->run;

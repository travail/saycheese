#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../../lib";
use SayCheese::CLI::Queue::Update::Title::Delete;

SayCheese::CLI::Queue::Update::Title::Delete->new_with_options->run;

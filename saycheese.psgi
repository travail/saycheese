#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use Plack::Builder;
use SayCheese

$ENV{DBIC_TRACE} = 1;

builder {
    enable 'Plack::Middleware::ReverseProxy';
    my $app = SayCheese->psgi_app(@_);
}

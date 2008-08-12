#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/ $Bin /;
use lib "$Bin/../lib";
use SayCheese::Utils qw/ url2thumbpath /;

$| = 1;
while (my $url = <>) {
    chomp $url;
    my $size = 'medium';
    ($size, $url) = split '/', $url, 2;
    my $thumbpath = url2thumbpath($url, $size);
    if (-e $thumbpath) {
        print "$thumbpath\n";
    } else {
        print sprintf qq{http://192.168.1.2:3010/%s/%s\n},$size, $url;
    }
}

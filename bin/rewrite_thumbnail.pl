#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw//;
use lib "$FindBin::Bin/../lib";
use SayCheese::Schema;
use SayCheese::Utils qw//;

$| = 1;
while (my $url = <>) {
    chomp $url;
    my $size = 'medium';
    ($size, $url) = split '/', $url, 2;
    my $thumbpath = SayCheese::Utils::url2thumbpath($url, $size);
    if (-e $thumbpath) {
        print "$thumbpath\n";
    } else {
        my $schema = SayCheese::Schema->connect(SayCheese::Utils::connect_info);
        my $thumbnail = $schema->resultset('Thumbnail')->find_by_url($url);
        if ($thumbnail) {
            print sprintf qq{%s\n}, $thumbnail->thumbnail_path(size => $size);
        } else {
            print sprintf qq{%s\n}, SayCheese::Utils::no_image_path($size);
        }
    }
}

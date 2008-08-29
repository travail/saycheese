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
            if ($size eq 'small') {
                print "/static/images/no_image_s.gif\n";
            } elsif ($size eq 'medium') {
                print "/static/images/no_image_m.gif\n";
            } elsif ($size eq 'large') {
                print "/static/images/no_image_l.gif\n";
            } else {
                print "/static/images/no_image_m.gif\n";
            }
        }
    }
}

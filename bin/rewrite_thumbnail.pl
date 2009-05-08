#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw();
use lib "$FindBin::Bin/../lib";
use SayCheese::API::Thumbnail;
use SayCheese::Utils qw();

$| = 1;
while ( my $url = <> ) {
    chomp $url;
    my $size = 'medium';
    ( $size, $url ) = split '/', $url, 2;
    my $thumbpath = SayCheese::Utils::url2thumbpath( $url, $size );
    if ( -e $thumbpath ) {
        print "$thumbpath\n";
    }
    else {
        my $api       = SayCheese::API::Thumbnail->new;
        my $thumbnail = $api->find_by_url($url);
        if ($thumbnail) {
            print sprintf qq{%s\n},
                $thumbnail->thumbnail_path( size => $size );
        }
        else {
            my $no_image_path = undef;
            if ( $size eq 'small' ) {
                $no_image_path = "/static/images/no_image_s.gif";
            }
            elsif ( $size eq 'medium' ) {
                $no_image_path = "/static/images/no_image_m.gif";
            }
            elsif ( $size eq 'large' ) {
                $no_image_path = "/static/images/no_image_l.gif";
            }
            else {
                $no_image_path = "/static/images/no_image_m.gif";
            }
            print "$no_image_path\n";
        }
    }
}

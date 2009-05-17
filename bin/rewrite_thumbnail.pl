#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw();
use lib "$FindBin::Bin/../lib";
use URI;
use SayCheese::API::Thumbnail;
use SayCheese::Utils qw();

use constant DEFAULT_SIZE => 'medium';

$| = 1;
while ( my $url = <> ) {
    chomp $url;
    my $size = DEFAULT_SIZE;
    ( $size, $url ) = split '/', $url, 2;
    $url = URI->new($url)->as_string;
    my $thumbpath = SayCheese::Utils::url2thumbpath( $url, $size );
    if ( -e $thumbpath ) {
        print "$thumbpath\n";
    }
    else {
        my $api       = SayCheese::API::Thumbnail->new;
        my $thumbnail = $api->find_by_url_like($url);
        if ($thumbnail) {
            print sprintf qq{%s\n},
                $thumbnail->thumbnail_path( size => $size );
        }
        else {
            my $no_image_path = '';
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

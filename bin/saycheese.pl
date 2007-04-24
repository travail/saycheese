#!/usr/bin/perl

use warnings;
use strict;
use POE;
use POE::Component::Server::TCP;
use FindBin;

use Data::Dumper;
use Image::Magick;
use lib "$FindBin::Bin/../lib";
use SayCheese;
use SayCheese::Schema;


$ENV{DISPLAY} = ':1.0';

POE::Component::Server::TCP->new(
    Port        => SayCheese->config->{saycheese}->{port},
    ClientInput => \&client_input,
);
POE::Kernel->run;
exit;

sub client_input {
    my ( $heap, $url ) = @_[HEAP, ARG0];

    ## make tmp image file
    my $tmp = sprintf q{%s/%d-%d.png}, SayCheese->config->{thumbnail}->{thumbnail_path}, time, $$;
    `firefox & firefox -display localhost:1 -remote "openurl($url)" -browser`;
    sleep 5;
    `import -display :1 -window root -silent $tmp`;

    my $img = Image::Magick->new;
    $img->Read( $tmp );
    $img->Set( quality => 90 );

    my $schema = SayCheese::Schema->connect( 'dbi:mysql:saycheese', 'travail', 'travail' );
    my $obj    = $schema->resultset('Thumbnail')->create( {
        created_on     => DateTime->now->set_time_zone('Asia/Tokyo'),
        modified_on    => DateTime->now->set_time_zone('Asia/Tokyo'),
        url            => $url,
        thumbnail_name => undef,
        extention      => 'png',
        filedata       => undef,
        width          => undef,
        height         => undef,
        filesize       => undef,
    } );

    ## make thumbnail
    my $thumb  = sprintf q{%s/%s.%s}, SayCheese->config->{thumbnail}->{thumbnail_path}, $obj->id, $obj->extention;
    $img->Scale( width => 256, height => 256 );
    my $cpy = $img->Clone;
    $cpy->Crop( height => 0, y => 29 );
    $cpy->Crop( height => 168, y => 0 );
    $cpy->Crop( width => 208, x => 0 );
    $cpy->Write( $thumb );
    unlink $tmp;

    my ( $width, $height, $filesize ) = $cpy->Get( 'width', 'height', 'filesize' );
    if ( $obj ) {
        $obj->width( $width );
        $obj->height( $height );
        $obj->filesize( $filesize );
        $obj->filedata( $cpy->ImageToBlob );
        $obj->update;
        $heap->{client}->put( $obj->id );
    } else {
        $heap->{client}->put( undef );
    }
}

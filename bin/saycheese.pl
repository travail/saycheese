#!/usr/bin/perl

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SayCheese;
use SayCheese::Schema;
use Gearman::Worker;
use Image::Magick;

$ENV{DISPLAY} = ':1.0';
my $worker = Gearman::Worker->new(
    job_servers => SayCheese->config->{job_servers},
);
$worker->register_function(
    saycheese => sub {
        my $job = shift;

        ## make tmp image file
        my $url = $job->arg;
        my $tmp = sprintf q{%s/%d-%d.png}, SayCheese->config->{thumbnail}->{thumbnail_path}, time, $$;
        `firefox & firefox -display localhost:1 -remote "openurl($url)"`;
        sleep 8;
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
        $cpy->Crop( width => 0, height => 0, x => 0, y => 29 );
        $cpy->Crop( width => 0, height => 168, x => 0, y => 0 );
        $cpy->Crop( width => 208, height => 0, x => 0, y => 0 );
        $cpy->Write( $thumb );
        unlink $tmp;

        my ( $width, $height, $filesize ) = $cpy->Get( 'width', 'height', 'filesize' );
        ## Return id, or undef.
        if ( $obj ) {
            $obj->width( $width );
            $obj->height( $height );
            $obj->filesize( $filesize );
            $obj->filedata( $cpy->ImageToBlob );
            $obj->update;
            return obj->id;
        } else {
            return undef;
        }
    }
);

$worker->work while 1;

#!/usr/bin/perl

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib '/home/public/cgi/lib';
use SayCheese;
use SayCheese::Schema;
use Gearman::Worker;
use Image::Magick;

my $config = SayCheese->config;
my $worker = Gearman::Worker->new(
    job_servers => $config->{job_servers},
);
$ENV{DISPLAY} = $config->{DISPLAY};
my $ff = 'firefox';
my $ext = 'jpg';
$worker->register_function(
    saycheese => sub {
        my $job = shift;

        ## make tmp image file
        my $url = $job->arg;
        warn "Starting saycheese.\n";
        warn "URL : $url\n";
        ## open URL
        my $tmp = sprintf q{%s/%d-%d.jpg}, $config->{thumbnail}->{thumbnail_path}, time, $$;
        my $cmd1 = sprintf q{%s -remote "openURL(%s)"}, $ff, $url;
        my $r1 = system $cmd1;
        warn "Execute command : $cmd1\n";
        if ( $r1 ) {
            warn "Can't render, $cmd1 return $r1.\n";
            exit;
        }
        warn "Rendering $url.\n";
        warn "sleep : 3 seconds\n";
        sleep 3;

        ## make original size image
        my $cmd2 = "import -display $ENV{DISPLAY} -window root -silent $tmp" . $ext;
        my $r2   = system $cmd2;
        warn "Execute command : $cmd2\n";
        if ( $r2 ) {
            warn "Can't import, $cmd2 return $r2.\n";
            exit;
        }

        my $schema = SayCheese::Schema->connect( @{$config->{'Model::SayCheese'}->{connect_info}} );
        my $obj    = $schema->resultset('Thumbnail')->update_or_create( {
            created_on     => DateTime->now->set_time_zone( $config->{time_zone} ),
            modified_on    => DateTime->now->set_time_zone( $config->{time_zone} ),
            url            => $url,
            thumbnail_name => undef,
            extention      => $ext,
            original       => undef,
            large          => undef,
            medium         => undef,
            small          => undef,
        }, 'unique_url' );

        ## make thumbnail
        my $thumb  = $obj->path;
        my $img    = Image::Magick->new;
        $img->Read( $tmp );
        $img->Set( quality => 100 );

        $img->Crop( width => 1200, height => 800, x => 5, y => 159 );
        warn "Write max size image, 1200x800.\n";
#        $img->Write( '/home/httpd/html/max.' . $ext );

        warn "Write medium size image, 200x150.\n";
        my $m = $img->Clone;
        $m->Scale( width => 200, height => 150 );
        $m->Write( $thumb );

        warn "Write small size image, 80x60.\n";
        my $s = $img->Clone;
        $s->Scale( width => 80, height => 60 );
#        $s->Write( '/home/httpd/html/small.' . $ext );
        unlink $tmp;

        ## Return id, or undef.
        if ( $obj ) {
            $obj->original( $img->ImageToBlob );
            $obj->large( undef );
            $obj->medium( $m->ImageToBlob );
            $obj->small( $s->ImageToBlob );
            $obj->update;
            warn "Finish saycheese.\n\n";
            return $obj->id;
        } else {
            warn "FAIL.\n";
            return undef;
        }
    }
);

$worker->work while 1;

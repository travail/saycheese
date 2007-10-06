#!/usr/bin/perl

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib '/home/public/cgi/lib';
use SayCheese;
use SayCheese::Schema;
use LWP::UserAgent;
use Gearman::Worker;
use Image::Magick;

my $config = SayCheese->config;
my $worker = Gearman::Worker->new(
    job_servers => $config->{job_servers},
);
$ENV{DISPLAY} = $config->{DISPLAY};
my $ff    = 'firefox';
my $ext   = 'jpg';
my $sleep = 10;
my $ua = LWP::UserAgent->new;
$ua->agent('SayCheese/1.0 ');
$ua->timeout( 10 );
$worker->register_function(
    saycheese => sub {
        my $job = shift;
        my $url = $job->arg;

        warn "Starting saycheese.\n";
        warn "URL : $url\n";
        ## Is finished?
        my $schema = SayCheese::Schema->connect( @{$config->{'Model::SayCheese'}->{connect_info}} );
        my $obj    = $schema->resultset('SayCheese::Schema::Thumbnail')->find_by_url( $url );
        if ( $obj ) {
            warn sprintf qq{%s already exists.\n}, $obj->url;
            if ( $obj->is_finished ) {
                warn sprintf qq{%s is already finished.\n\n}, $obj->url;
                return $obj->id;
            }
        }

        ## URL exists?
        my $res = $ua->get( $url );
        if ( $res->is_success ) {
            warn "$url exists.\n";
        } else {
            warn sprintf qq{*** %s. ***\n}, $res->status_line;
            warn "*** $url does not exist. ***\n\n";
            next;
        }

        warn "Starting saycheese.\n";
        warn "URL : $url\n";
        ## open URL
        my $tmp  = sprintf q{%s/%d-%d.%s}, $config->{thumbnail}->{thumbnail_path}, time, $$, $ext;
        my $cmd1 = sprintf q{%s -remote "openURL(%s)"}, $ff, $url;
        my $r1   = system $cmd1;
        warn "Execute command : $cmd1\n";
        if ( $r1 ) {
            warn "Can't render, $cmd1 return $r1.\n";
            exit;
        }
        warn "Rendering $url.\n";
        warn "sleep : $sleep seconds\n";
        sleep $sleep;

        ## make original size image
        my $cmd2 = "import -display $ENV{DISPLAY} -window root -silent $tmp";
        my $r2   = system $cmd2;
        warn "Execute command : $cmd2\n";
        if ( $r2 ) {
            warn "Can't import, $cmd2 return $r2.\n";
            exit;
        }

        $obj = $schema->resultset('Thumbnail')->update_or_create( {
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

        $img->Crop( width => 1200, height => 800, x => 5, y => 115 );
        warn "Write max size image, 1200x800.\n";

        my $l = $img->Clone;
        $l->Scale( width => 400, height => 300 );
        warn "Write large size image, 400x300.\n";

        my $m = $img->Clone;
        $m->Scale( width => 200, height => 150 );
        $m->Write( $thumb );
        warn "Write medium size image, 200x150.\n";

        my $s = $img->Clone;
        $s->Scale( width => 80, height => 60 );
        warn "Write small size image, 80x60.\n";

        unlink $tmp;
        warn "Unlink $tmp.\n";

        ## Return id, or undef.
        if ( $obj ) {
            $obj->original( $img->ImageToBlob );
            $obj->large( $l->ImageToBlob );
            $obj->medium( $m->ImageToBlob );
            $obj->small( $s->ImageToBlob );
            $obj->is_finished( 1 );
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

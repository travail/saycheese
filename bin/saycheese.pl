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
my $worker = Gearman::Worker->new( job_servers => $config->{job_servers} );
my $ff     = 'firefox';
my $ext    = 'jpg';
my $sleep  = 15;
my $ua     = LWP::UserAgent->new(
    agent   => $config->{user_agent}->{agent},
    from    => $config->{user_agent}->{from},
    timeout => $config->{user_agent}->{timeout},
);
$ua->default_header( Accept => [ qw(text/html text/plain image/*) ] );
$ENV{DISPLAY} = $config->{DISPLAY};
$worker->register_function(
    saycheese => sub {
        my $job = shift;
        my $url = $job->arg;

        warn "STARTING saycheese.pl\n";
        warn "URL : $url\n";
        ## Valid extension?
        $url =~ /(.*)\.(.*)/;
        if ( grep { $2 eq $_ } @{$config->{invalid_extension}} ) {
            warn "WARN : $2 is invalid extension.\n";
            warn "FAIL saycheese.pl\n\n";
            return;
        }
        ## Is finished?
        my $schema = SayCheese::Schema->connect( @{$config->{'Model::SayCheese'}->{connect_info}} );
        my $obj    = $schema->resultset('SayCheese::Schema::Thumbnail')->find_by_url( $url );
        if ( $obj ) {
            warn sprintf qq{EXISTS : %s exists as id %d.\n}, $obj->url, $obj->id;
            if ( $obj->is_finished ) {
                warn sprintf qq{ALREADY FINISHED : %s is already finished as id %d.\n}, $obj->url, $obj->id;
                warn "FINISH saycheese.pl\n\n";
                return $obj->id;
            }
        }

        ## URL exists?
        warn "FETCHIGN DOCUMENT : $url\n";
        my $res = $ua->get( $url );
        if ( $res->is_success ) {
            warn "OK : $url exists.\n";
        } else {
            warn sprintf qq{ERROR : %s.\n}, $res->status_line;
            warn "FAIL saycheese.pl\n\n";
            return;
        }

        ## open URL
        my $tmp  = sprintf q{%s/%d-%d.%s}, $config->{thumbnail}->{thumbnail_path}, time, $$, $ext;
        my $cmd1 = sprintf q{%s -remote "openURL(%s)"}, $ff, $url;
        my $r1   = system $cmd1;
        warn "EXECUTE COMMAND : $cmd1\n";
        if ( $r1 ) {
            warn "ERROR : Can't render, $cmd1 return $r1.\n";
            warn "FAIL saycheese.pl\n\n";
            return;
        }
        warn "RENDERING : $url\n";
        warn "SLEEP : $sleep seconds\n";
        sleep $sleep;

        ## make original size image
        my $cmd2 = "import -display $ENV{DISPLAY} -window root -silent $tmp";
        my $r2   = system $cmd2;
        warn "EXECUTE COMMAND : $cmd2\n";
        if ( $r2 ) {
            warn "ERROR : Can't import, $cmd2 return $r2.\n";
            warn "FAIL saycheese.pl\n\n";
            return;
        }

        $obj = $schema->resultset('Thumbnail')->update_or_create( {
            created_on     => DateTime->now->set_time_zone( $config->{time_zone} ),
            modified_on    => DateTime->now->set_time_zone( $config->{time_zone} ),
            url            => $url,
            thumbnail_name => undef,
            extension      => $ext,
            original       => undef,
            large          => undef,
            medium         => undef,
            small          => undef,
        }, 'unique_url' );
        warn sprintf qq{UPDATE OR CREATE : %s as id %d.\n}, $obj->url, $obj->id;

        ## make thumbnail
        my $thumb  = $obj->path;
        my $img    = Image::Magick->new;
        $img->Read( $tmp );
        $img->Set( quality => 100 );

        $img->Crop( width => 1200, height => 800, x => 5, y => 115 );
        warn "WRITING IMAGE : max size image, 1200x800.\n";

        my $l = $img->Clone;
        $l->Scale( width => 400, height => 300 );
        warn "WRITING IMAGE : large size image, 400x300.\n";

        my $m = $img->Clone;
        $m->Scale( width => 200, height => 150 );
        $m->Write( $thumb );
        warn "WRITING IMAGE : medium size image, 200x150.\n";

        my $s = $img->Clone;
        $s->Scale( width => 80, height => 60 );
        warn "WRITING IMAGE : small size image, 80x60.\n";

        unlink $tmp;
        warn "UNLINK : $tmp.\n";

        ## Return id, or undef.
        if ( $obj ) {
            $obj->original( $img->ImageToBlob );
            $obj->large( $l->ImageToBlob );
            $obj->medium( $m->ImageToBlob );
            $obj->small( $s->ImageToBlob );
            $obj->is_finished( 1 );
            $obj->update;
            warn "FINISH saycheese.pl\n\n";
            return $obj->id;
        } else {
            warn "FAIL saycheese.pl\n\n";
            return;
        }
    }
);

$worker->work while 1;

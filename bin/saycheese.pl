#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/ $Bin /;
use lib "$Bin/../lib";
use SayCheese::ConfigLoader;
use SayCheese::Constants;
use SayCheese::DateTime;
use SayCheese::Schema;
use SayCheese::UserAgent;
use Digest::MD5 qw/ md5_hex /;
use Image::Magick;
use Gearman::Worker;
use Data::Dumper;

my $config = SayCheese::ConfigLoader->new->config;
my $worker = Gearman::Worker->new( job_servers => $config->{job_servers} );
my $ff     = 'firefox';
my $ext    = $config->{thumbnail}->{extension};
my $sleep  = 15;
my $ua     = SayCheese::UserAgent->new;
$ENV{DISPLAY} = $config->{DISPLAY};

$worker->register_function(
    saycheese => sub {
        my $job = shift;
        my $url = $job->arg;

        warn "STARTING saycheese.pl\n";
        warn "URL :$url\n";

        ## valid schema?
        $url =~ /^(.*:\/\/)/;
        if ( grep { $1 eq $_ } @{$config->{invalid_schema}} ) {
            warn "WARN :$2 is invalid schema.\n";
            warn "FAIL saycheese.pl\n\n";
            return FAIL;
        }

        ## valid extension?
        $url =~ /(.*)\.(.*)/;
        if ( grep { $2 eq $_ } @{$config->{invalid_extension}} ) {
            warn "WARN :$2 is invalid extension.\n";
            warn "FAIL saycheese.pl\n\n";
            return FAIL;
        }

        ## finished?
        my $schema = SayCheese::Schema->connect( @{$config->{'Model::DBIC::SayCheese'}->{connect_info}} );
        my $obj    = $schema->resultset('Thumbnail')->find_by_url( $url );
        if ( $obj ) {
            warn sprintf qq{EXISTS :%s exists as id %d.\n}, $obj->url, $obj->id;
            if ( $obj->is_finished ) {
                warn sprintf qq{ALREADY FINISHED :%s is already finished as id %d.\n}, $obj->url, $obj->id;
                warn "FINISH saycheese.pl\n\n";
                return $obj->id;
            }
        }

        ## URL exists?
        warn "FETCHIGN DOCUMENT :$url\n";
        my $res = $ua->get( $url );
        if ( $res->is_success ) {
            warn "OK :$url exists.\n";
        } else {
            warn sprintf qq{ERROR :%s.\n}, $res->status_line;
            warn "FAIL saycheese.pl\n\n";
            return FAIL;
        }

        ## open URL
        my $tmp  = sprintf q{/tmp/%d-%d.%s}, time, $$, $ext;
        my $cmd1 = sprintf q{%s -remote "openURL(%s)"}, $ff, $url;
        my $r1   = system $cmd1;
        warn "EXECUTE COMMAND :$cmd1\n";
        if ( $r1 ) {
            warn "ERROR :Can't render, $cmd1 return $r1.\n";
            warn "FAIL saycheese.pl\n\n";
            return FAIL;
        }
        warn "RENDERING :$url\n";
        warn "SLEEP :$sleep seconds\n";
        sleep $sleep;

        ## make original size thumbnail
        my $cmd2 = "import -display $ENV{DISPLAY} -window root -silent $tmp";
        my $r2   = system $cmd2;
        warn "EXECUTE COMMAND :$cmd2\n";
        if ( $r2 ) {
            warn "ERROR :Can't import, $cmd2 return $r2.\n";
            warn "FAIL saycheese.pl\n\n";
            return FAIL;
        }

        my $now = SayCheese::DateTime->now;
        $obj = $schema->resultset('Thumbnail')->update_or_create( {
            created_on  => $now,
            modified_on => $now,
            url         => $url,
            digest      => md5_hex( $url ),
        }, 'unique_url' );
        warn sprintf qq{UPDATE OR CREATE :%s as id %d.\n}, $obj->url, $obj->id;

        ## make thumbnails
        my $img = Image::Magick->new;
        $img->Read( $tmp );
        $img->Set( quality => 100 );
        $img->Crop( width => ORIGINAL_WIDTH, height => ORIGINAL_HEIGHT, x => 7, y => 116 );

        ## original size
        $img->Write( $obj->original_path );
        warn sprintf qq{WRITING THUMBNAIL :original size tumbnail, %d x %d.\n}, ORIGINAL_WIDTH, ORIGINAL_HEIGHT;

        ## large size
        my $l = $img->Clone;
        $l->Scale( width => LARGE_WIDTH, height => LARGE_HEIGHT );
        $l->Write( $obj->large_path );
        warn sprintf qq{WRITING THUMBNAIL :large size thumbnail, %d x %d.\n}, LARGE_WIDTH, LARGE_HEIGHT;

        ## medium size
        my $m = $img->Clone;
        $m->Scale( width => MEDIUM_WIDTH, height => MEDIUM_HEIGHT );
        $m->Write( $obj->medium_path );
        warn sprintf qq{WRITING THUMBNAIL :medium size thumbnail, %d x %d.\n}, MEDIUM_WIDTH, MEDIUM_HEIGHT;

        ## small size
        my $s = $img->Clone;
        $s->Scale( width => SMALL_WIDTH, height => SMALL_HEIGHT );
        $s->Write( $obj->small_path );
        warn sprintf qq{WRITING THUMBNAIL :small size thumbnail, %d x %d.\n}, SMALL_WIDTH, SMALL_HEIGHT;

        unlink $tmp;
        warn "UNLINK :$tmp.\n";

        ## return id, or FAIL(0)
        if ( $obj ) {
            $obj->is_finished( 1 );
            $obj->update;
            warn "FINISH saycheese.pl\n\n";
            return $obj->id;
        } else {
            warn "FAIL saycheese.pl\n\n";
            return FAIL;
        }
    }
);

while ( 1 ) {
    local $Data::Dumper::Terse = 1;
    warn "=== WORKER START ===\n";
    warn "ENV :" . Dumper( \%ENV );
    $worker->work;
}

package SayCheese::Gearman::Worker::SayCheese;

use strict;
use warnings;
use base qw( SayCheese::Gearman::Worker::Root );
use Data::Dumper;
use Digest::MD5 qw();
use Image::Magick;
use Storable qw();
use SayCheese::API::Thumbnail;
use SayCheese::Config;
use SayCheese::Constants;
use SayCheese::DateTime;
use SayCheese::Log;
use SayCheese::Timer;
use SayCheese::UserAgent;

__PACKAGE__->mk_accessors(qw( browser config debug thumbnail user_agent img ));
__PACKAGE__->functions( [qw( saycheese )] );

=head1 NAME

SayCheese::Gearman::Worker::SayCheese - SayCheese Worker

=head1 DESCRIPTION

SayCheese Worker

=head1 METHODS

=cut

=head2 new

=cut

sub new {
    my ( $class, %args ) = @_;

    $args{browser}    ||= 'firefox';
    $args{config}     ||= SayCheese::Config->instance->config;
    $args{user_agent} ||= SayCheese::UserAgent->new;
    $args{wait}       ||= 10;

    my $self = bless {
        browser    => $args{browser}                 || undef,
        config     => $args{config}                  || undef,
        debug      => $args{debug}                   || undef,
        img        => undef,
        log        => SayCheese::Log->new            || undef,
        timer      => SayCheese::Timer->new          || undef,
        tmpfile    => undef,
        thumbnail  => SayCheese::API::Thumbnail->new || undef,
        user_agent => $args{user_agent}              || undef,
        wait       => $args{wait}                    || undef,
    }, $class;

    $ENV{DISPLAY} = $self->config->{DISPLAY};

    return $self;
}

=head2 on_work

=cut

sub on_work {
    my $self = shift;

    $Data::Dumper::Terse = 1;
    $self->log->info('=== STARTING saycheesed ===');
    $self->log->info( Dumper( \%ENV ) );
    $self->log->_flush;
}

=head2 saycheese

=cut

sub saycheese {
    my ( $self, $freezed_job ) = @_;

    $self->timer->start;
    my $job = Storable::thaw( $freezed_job->arg );
    my $url = $job->{url};
    $self->log->info("Start to saycheese $url");

    # finished?
    my $obj = $self->{thumbnail}->find_by_url($url);
    if ($obj) {
        $self->log->info( sprintf 'Already exists as id %d', $obj->id );
        if ( $obj->is_finished ) {
            $self->log->info('Already finished');
            $self->log->info("Finish to saycheese\n\n");
            $self->log->_flush;
            return $obj->id;
        }
    }

    # valid scheme?
    if ( !SayCheese::Utils::is_valid_scheme( $url ) ) {
        $self->log->error('Invalid scheme');
        $self->log->info("Finish to saycheese\n\n");
        $self->log->_flush;
        return FAILURE;
    }

    # valid URI
    if ( !SayCheese::Utils::is_valid_uri( $url ) ) {
        $self->log->error('Invalid URI');
        $self->log->info("Finish to saycheese\n\n");
        $self->log->_flush;
        return FAILURE;
    }

    # valid extension?
    if ( !SayCheese::Utils::is_valid_extension( $url ) ) {
        $self->log->errror('Invalid extension');
        $self->log->info("Finish to saycheese\n\n");
        $self->log->_flush;
        return FAILURE;
    }

    # URL exists?
    $self->log->info('Fetching document');
    $self->timer->set_mark('t0');
    my $res = $self->user_agent->get( $url );
    $self->timer->set_mark('t1');
    $self->log->debug(
        sprintf 'Took %s seconds to fetch document',
        $self->timer->get_diff_time( 't0', 't1' )
    );
    if ( !$res->is_success ) {
        $self->log->error( $res->status_line );
        $self->log->info("Finish to saycheese\n\n");
        $self->log->_flush;
        return FAILURE;
    }

    # valid Conetnt-Type?
    my $content_type = $res->headers->header('content_type');
    if ( !SayCheese::Utils::is_valid_content_type($content_type) ) {
        $self->log->error("$content_type is invalid");
        $self->log->info("Finish to saycheese\n\n");
        $self->log->_flush;
        return FAILURE;
    }

    # open URL
    my $r1 = $self->open_url($url);
    if ($r1) {
        $self->log->error("Can't open URL, open_url() returned $r1");
        $self->log->info("Finish to saycheese\n\n");
        $self->log->_flush;
        return FAILURE;
    }
    $self->log->info("Rendering $url");
    $self->wait;

    # make original size thumbnail
    my $r2 = $self->import_display;
    if ( $r2 ) {
        $self->log->error("Can't import, import_display() returned $r2");
        $self->log->info("Finish to saycheese\n\n");
        $self->log->_flush;
        return FAILURE;
    }

    my $now = SayCheese::DateTime->now;
    $obj = $self->{thumbnail}->update_or_create(
        {
            created_on  => $now                       || undef,
            modified_on => $now                       || undef,
            url         => $url                       || undef,
            digest      => Digest::MD5::md5_hex($url) || undef,
        },
        { key => 'unique_url' }
    );
    $self->log->info( sprintf "Create thumbnail %s as id %d",
        $obj->url, $obj->id );

    # make thumbnails
    $self->create_img( path => $self->tmpfile_path, width => ORIGINAL_WIDTH, height => ORIGINAL_HEIGHT );
#    $self->write_thumbnail( path => $obj->original_path, width => ORIGINAL_WIDTH, height => ORIGINAL_HEIGHT );
    $self->write_thumbnail( path => $obj->large_path,    width => LARGE_WIDTH,    height => LARGE_HEIGHT    );
    $self->write_thumbnail( path => $obj->medium_path,   width => MEDIUM_WIDTH,   height => MEDIUM_HEIGHT   );
    $self->write_thumbnail( path => $obj->small_path,    width => SMALL_WIDTH,    height => SMALL_HEIGHT    );

    $self->unlink_tmpfile;
    $self->saycheese_free;
    $self->log->info( sprintf 'Took %s seconds',
        $self->timer->get_total_time );

    # return thumbnail id, or FAILURE(0)
    if ($obj) {
        $obj->is_finished(1);
        $obj->update;
        $self->log->info("Finish to saycheese\n\n");
        $self->log->_flush;
        return $obj->id;
    }
    else {
        $self->log->error("Finish to saycheese\n\n");
        $self->log->_flush;
        return FAILURE;
    }
}

=head2 tmpfile

=cut

sub tmpfile {
    my $self = shift;

    if ( defined $self->{tmpfile} ) {
        return $self->{tmpfile};
    }
    else {
        $self->{tmpfile} = sprintf q{%d-%d.%s}, time, $$,
            $self->config->{thumbnail}->{extension};
        return $self->{tmpfile};
    }
}

=head2 tmpfile_path

=cut

sub tmpfile_path { sprintf q{/tmp/%s}, shift->tmpfile }

=head2 unlink_tmpfile

=cut

sub unlink_tmpfile {
    my $self = shift;

    $self->log->info( sprintf 'Unlink tmp file %s', $self->tmpfile_path );
    unlink $self->tmpfile_path
        or $self->log->error( sprintf "Can't unlink tmpfile %s",
        $self->tmpfile_path );
}

=head2 wait

=cut

sub wait {
    my $self = shift;

    $self->log->info( sprintf 'Wait %d seconds...', $self->{wait} );
    sleep $self->{wait};
}

=head2 open_url

=cut

sub open_url {
    my ( $self, $url ) = @_;

    my $cmd = sprintf q{%s -remote "openURL(%s)"}, $self->browser, $url;
    $self->log->info("Execute command $cmd");

    return system $cmd;
}

=head2 import_display

=cut

sub import_display {
    my $self = shift;

    my $cmd = sprintf qq{import -display %s -window root -silent %s},
        $ENV{DISPLAY}, $self->tmpfile_path;
    $self->info("Execute command $cmd");

    return system $cmd;
}
 

=head2 create_img

=cut

sub create_img {
    my ( $self, %args ) = @_;

    $args{quality} ||= 100;
    my $img = Image::Magick->new;
    $img->Read( $args{path} );
    $img->Set( quality => $args{quality} );
    $img->Crop(
        width  => $args{width},
        height => $args{height},
        x      => 7,
        y      => 116
    );
    $self->img($img);
}

=head2 write_thumbnail

=cut

sub write_thumbnail {
    my ( $self, %args ) = @_;

    my $clone = $self->img->Clone;
    $clone->Scale( width => $args{width}, height => $args{height} );
    $clone->Write( $args{path} );
    $self->log->info( sprintf 'Writing thumbnail %d x %d, %s',
        $args{width}, $args{height}, $args{path} );
}

=head2 saycheese_free

=cut

sub saycheese_free {
    my $self = shift;

    $self->log->info('Clean up img(), tmpfile()');
    $self->img(undef);
    $self->tmpfile(undef);
}

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

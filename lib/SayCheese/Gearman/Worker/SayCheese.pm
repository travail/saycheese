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
use SayCheese::UserAgent;

__PACKAGE__->mk_accessors(qw( browser config debug user_agent img ));
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
    $args{wait}       ||= 15;

    my $self = bless {
        browser    => $args{browser}    || undef,
        config     => $args{config}     || undef,
        debug      => $args{debug}      || undef,
        img        => undef,
        tmpfile    => undef,
        user_agent => $args{user_agent} || undef,
        wait       => $args{wait}       || undef,
    }, $class;

    $ENV{DISPLAY} = $self->config->{DISPLAY};

    return $self;
}

=head2 on_work

=cut

sub on_work {
    my $self = shift;

    $Data::Dumper::Terse = 1;
    warn "=== STARTING saycheesed ===\n";
    warn Dumper( \%ENV );
}

=head2 saycheese

=cut

sub saycheese {
    my ( $self, $freezed_job ) = @_;

    my $job = Storable::thaw( $freezed_job->arg );
    my $url = $job->{url};
    warn "INFO: URL is $url\n";

    # valid scheme?
    if ( !SayCheese::Utils::is_valid_scheme( $url ) ) {
        warn "WARN: $url is invalid scheme.\n";
        warn "WARN: Finish saycheese\n\n";
        return FAILURE;
    }

    # valid extension?
    if ( !SayCheese::Utils::is_valid_extension( $url ) ) {
        warn "WARN: $url is invalid extension.\n";
        warn "WARN: Finish saycheese\n\n";
        return FAILURE;
    }

    # finished?
    my $api = SayCheese::API::Thumbnail->new;
    my $obj = $api->find_by_url($url);
    if ($obj) {
        warn sprintf qq{INFO: %s exists as id %d.\n}, $obj->url, $obj->id;
        if ( $obj->is_finished ) {
            warn sprintf qq{INFO: %s is already finished.\n}, $obj->url;
            warn "INFO: Finish saycheesel\n\n";
            return $obj->id;
        }
    }

    # URL exists?
    warn "INFO: Fetching document $url\n";
    my $res = $self->user_agent->get( $url );
    if ( !$res->is_success ) {
        warn sprintf qq{ERROR: %s.\n}, $res->status_line;
        warn "INFO: Finish saycheese\n\n";
        return FAILURE;
    }

    # open URL
    my $r1 = $self->open_url( $url );
    if ( $r1 ) {
        warn "ERROR: Can't open URL, open_url() returned $r1.\n";
        warn "WARN: Finish saycheese\n\n";
        return FAILURE;
    }
    warn "INFO: Rendering $url\n";
    $self->wait;

    # make original size thumbnail
    my $r2 = $self->import_display;
    if ( $r2 ) {
        warn "ERROR: Can't import, import_display() returned $r2.\n";
        warn "WARN: Finish  saycheese\n\n";
        return FAILURE;
    }

    my $now = SayCheese::DateTime->now;
    $obj = $api->create(
        {
            created_on  => $now                       || undef,
            modified_on => $now                       || undef,
            url         => $url                       || undef,
            digest      => Digest::MD5::md5_hex($url) || undef,
        },
        { key => 'unique_url' }
    );
    warn sprintf qq{INFO: Create thumbnail %s as id %d.\n}, $obj->url,
        $obj->id;

    # make thumbnails
    $self->create_img( path => $self->tmpfile_path, width => ORIGINAL_WIDTH, height => ORIGINAL_HEIGHT );
    $self->write_thumbnail( path => $obj->original_path, width => ORIGINAL_WIDTH, height => ORIGINAL_HEIGHT );
    $self->write_thumbnail( path => $obj->large_path,    width => LARGE_WIDTH,    height => LARGE_HEIGHT    );
    $self->write_thumbnail( path => $obj->medium_path,   width => MEDIUM_WIDTH,   height => MEDIUM_HEIGHT   );
    $self->write_thumbnail( path => $obj->small_path,    width => SMALL_WIDTH,    height => SMALL_HEIGHT    );

    $self->unlink_tmpfile;
    $self->saycheese_free;

    # return thumbnail id, or FAILURE(0)
    if ($obj) {
        $obj->is_finished(1);
        $obj->update;
        warn "INFO: Finish saycheese\n\n";
        return $obj->id;
    }
    else {
        warn "ERROR: Finish saycheese\n\n";
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

    warn sprintf "INFO: unlink file %s.\n", $self->tmpfile_path;
    unlink $self->tmpfile_path
        or warn sprintf "ERROR: Can't unlink tmpfile %s", $self->tmpfile_path;
}

=head2 wait

=cut

sub wait {
    my $self = shift;

    warn sprintf "INFO: Wait %d seconds...\n", $self->{wait};
    sleep $self->{wait};
}

=head2 open_url

=cut

sub open_url {
    my ( $self, $url ) = @_;

    my $cmd = sprintf q{%s -remote "openURL(%s)"}, $self->browser, $url;
    warn "INFO: Execute command $cmd\n";

    return system $cmd;
}

=head2 import_display

=cut

sub import_display {
    my $self = shift;

    my $cmd = sprintf "import -display %s -window root -silent %s",
        $ENV{DISPLAY}, $self->tmpfile_path;
    warn "INFO: Execute command $cmd\n";

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
    warn sprintf qq{INFO: Writing thumbnail (%d x %d), %s.\n},
        $args{width}, $args{height}, $args{path};
}

=head2 saycheese_free

=cut

sub saycheese_free {
    my $self = shift;

    warn "INFO: Clean up img(), tmpfile().\n";
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

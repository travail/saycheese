package SayCheese::Gearman::Worker::SayCheese;

use strict;
use warnings;
use base qw/ SayCheese::Gearman::Worker::Root /;
use SayCheese::ConfigLoader;
use SayCheese::Constants;
use SayCheese::DateTime;
use SayCheese::Schema;
use SayCheese::UserAgent;
use Digest::MD5 qw//;
use Image::Magick;
use Data::Dumper;

__PACKAGE__->mk_accessors( qw/ browser config user_agent img wait / );
__PACKAGE__->functions( [ qw/ saycheese / ] );

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

    $args{browser} ||= 'firefox';
    $args{config} ||= SayCheese::ConfigLoader->new->config;
    $args{user_agent} ||= SayCheese::UserAgent->new;
    $args{wait} ||= 15;

    my $self = bless {
        browser      => $args{browser},
        config       => $args{config},
        tmpfile      => undef,
        user_agent   => $args{user_agent},
        wait         => $args{wait},
    }, $class;

    $ENV{DISPLAY} = $self->config->{DISPLAY};

    return $self;
}

=head2 saycheese

=cut

sub saycheese {
    my ( $self, $job ) = @_;

    my $url = $job->arg;

    warn "STARTING saycheese\n";
    warn "URL :$url\n";

    ## valid schema?
    unless ( SayCheese::Utils::is_valid_scheme( $url ) ) {
        warn "WARN :$2 is invalid scheme.\n";
        warn "FINISH saycheese\n\n";
        return FAILURE;
    }

    ## valid extension?
    unless ( SayCheese::Utils::is_valid_extension( $url ) ) {
        warn "WARN :$2 is invalid extension.\n";
        warn "FINISH saycheese\n\n";
        return FAILURE;
    }

    ## finished?
    my $schema = SayCheese::Schema->connect( SayCheese::Utils::connect_info );
    my $obj    = $schema->resultset('Thumbnail')->find_by_url( $url );
    if ( $obj ) {
        warn sprintf qq{EXISTS :%s exists as id %d.\n}, $obj->url, $obj->id;
        if ( $obj->is_finished ) {
            warn sprintf qq{FINISHED :%s is already finished as id %d.\n},
                $obj->url, $obj->id;
            warn "FINISH saycheesel\n\n";
            return $obj->id;
        }
    }

    ## URL exists?
    warn "FETCHIGN DOCUMENT :$url\n";
    my $res = $self->user_agent->get( $url );
    unless ( $res->is_success ) {
        warn sprintf qq{ERROR :%s.\n}, $res->status_line;
        warn "FAILURE saycheese\n\n";
        return FAILURE;
    }
    warn "OK :$url exists.\n";

    ## open URL
    my $r1 = $self->open_url( $url );
    if ( $r1 ) {
        warn "ERROR :Can't open url, open_url() returned $r1.\n";
        warn "FAILURE saycheese\n\n";
        return FAILURE;
    }

    warn "RENDERING :$url\n";
    warn sprintf "WAIT... :%d seconds\n", $self->wait;
    sleep $self->wait;

    ## make original size thumbnail
    my $r2 = $self->import_display;
    if ( $r2 ) {
        warn "ERROR :Can't import, import_display() returned $r2.\n";
        warn "FAILURE saycheese\n\n";
        return FAILURE;
    }

    my $now = SayCheese::DateTime->now;
    $obj = $schema->resultset('Thumbnail')->update_or_create( {
        created_on  => $now                       || undef,
        modified_on => $now                       || undef,
        url         => $url                       || undef,
        digest      => Digest::MD5::md5_hex($url) || undef,
    }, {key => 'unique_url'} );
    warn sprintf qq{UPDATE OR CREATE :%s as id %d.\n}, $obj->url, $obj->id;

    ## make thumbnails
    $self->create_img( path => $self->tmpfile_path, width => ORIGINAL_WIDTH, height => ORIGINAL_HEIGHT );
    $self->create_thumbnail( path => $obj->original_path, width => ORIGINAL_WIDTH, height => ORIGINAL_HEIGHT );
    $self->create_thumbnail( path => $obj->large_path,    width => LARGE_WIDTH,    height => LARGE_HEIGHT    );
    $self->create_thumbnail( path => $obj->medium_path,   width => MEDIUM_WIDTH,   height => MEDIUM_HEIGHT   );
    $self->create_thumbnail( path => $obj->small_path,    width => SMALL_WIDTH,    height => SMALL_HEIGHT    );

    $self->unlink_tmpfile;
    $self->saycheese_free;

    ## return id, or FAILURE(0)
    if ( $obj ) {
        $obj->is_finished( 1 );
        $obj->update;
        warn "FINISH saycheese\n\n";
        return $obj->id;
    } else {
        warn "FAILURE saycheese\n\n";
        return FAILURE;
    }
}

=head2 tmpfile

=cut

sub tmpfile {
    my $self = shift;

    if ( defined $self->{tmpfile} ) {
        return $self->{tmpfile};
    } else {
        $self->{tmpfile}
            = sprintf q{%d-%d.%s}, time, $$, $self->config->{thumbnail}->{extension};
    }
}

=head2 tmpfile_path

=cut

sub tmpfile_path { sprintf q{/tmp/%s}, shift->tmpfile }

=head2 unlink_tmpfile

=cut

sub unlink_tmpfile {
    my $self = shift;

    warn sprintf "UNLINK :%s.\n", $self->tmpfile_path;
    unlink $self->tmpfile_path
        or warn sprintf "ERROR :Can't unlink tmpfile %s", $self->tmpfile_path;
}

=head2 open_url

=cut

sub open_url {
    my ( $self, $url ) = @_;

    my $cmd = sprintf q{%s -remote "openURL(%s)"}, $self->browser, $url;
    warn "EXECUTE COMMAND :$cmd\n";

    return system $cmd;
}

=head2 import_display

=cut

sub import_display {
    my $self = shift;

    my $cmd = sprintf "import -display %s -window root -silent %s",
        $ENV{DISPLAY}, $self->tmpfile_path;
    warn "EXECUTE COMMAND :$cmd\n";

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
    $img->Crop( width => $args{width}, height => $args{height}, x => 7, y => 116 );
    $self->img( $img );
}

=head2 create_thumbnail

=cut

sub create_thumbnail {
    my ( $self, %args ) = @_;

    my $clone = $self->img->Clone;
    $clone->Scale( width => $args{width}, height => $args{height} );
    $clone->Write( $args{path} );
    warn sprintf qq{WRITING THUMBNAIL :large size (%d x %d), %s.\n},
        $args{width}, $args{height}, $args{path};
}

=head2 saycheese_free

=cut

sub saycheese_free {
    my $self = shift;

    warn "CLEAN UP img(), tmpfile().\n";
    $self->img( undef );
    $self->tmpfile( undef );
}

=head1 AUTHOR

travail

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

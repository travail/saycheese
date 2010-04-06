package SayCheese::Queue::Worker::SayCheese;

use Moose;
use Digest::MD5 ();
use Image::Magick;
use SayCheese::API::Thumbnail;
use SayCheese::Constants;
use SayCheese::DateTime;
use SayCheese::UserAgent;

extends 'SayCheese::Queue::Worker';

has 'thumbnail' => (
    is       => 'ro',
    isa      => 'SayCheese::API::Thumbnail',
    required => 1,
    lazy     => 1,
    builder  => '_build_thumbnail'
);

has 'image' => (
    is       => 'rw',
    isa      => 'Image::Magick',
    required => 1,
    lazy     => 1,
    builder  => '_build_image'
);

has 'user_agent' => (
    is       => 'rw',
    isa      => 'SayCheese::UserAgent',
    required => 1,
    lazy     => 1,
    builder  => '_build_user_agent',
);

has 'interval' => (
    is  => 'rw',
    isa => 'Int',
);

sub _build_thumbnail  { SayCheese::API::Thumbnail->new }
sub _build_user_agent { SayCheese::UserAgent->new }
sub _build_image      { Image::Magick->new }

sub BUILD {
    my $self = shift;

    $self->interval( $self->config->{$self->meta->name}->{interval} )
        if !$self->interval;
}

sub _work {
    my $self = shift;

    while ( my $ret = $self->next ) {
        $self->timer->start;
        $self->log->debug("PID: $$ Working");
        my $q   = $self->dequeue_hashref;
        my $url = $q->{url};
        $self->log->info("Start to saycheese $url");

        # finished?
        my $obj = $self->thumbnail->find_by_url($url);
        if ($obj) {
            $self->log->info( 'Already exists ' . $obj->id );
            if ($obj->is_finished) {
                $self->log->info('Already finished');
                $self->log->info("Finish to saycheese\n\n");
                $self->log->_flush;
                return $obj->id;
            }
        }

        # valid schema?
        if ( !SayCheese::Utils::is_valid_scheme($url) ) {
            $self->log->error('Invalid scheme');
            $self->log->info("Finish to saycheese\n\n");
            $self->log->_flush;
            return FAILURE;
        }

        # valid URI
        if ( !SayCheese::Utils::is_valid_uri($url) ) {
            $self->log->error('Invalid URI');
            $self->log->info("Finish to saycheese\n\n");
            $self->log->_flush;
            return FAILURE;
        }

        # URL exists?
        $self->log->info('Fetching the document');
        $self->timer->set_mark('t0');
        my $res = $self->user_agent->get($url);
        $self->timer->set_mark('t1');
        $self->log->debug(
            sprintf 'Took %.5f seconds to fetch document',
            $self->timer->get_diff_time( 't0', 't1' )
        );

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
        $self->log->info( sprintf 'Wait %d seconds...', $self->interval );
        $self->wait;

        my $now = SayCheese::DateTime->now;
        $obj = $self->thumbnail->create(
            {
                created_on => $now                       || undef,
                url        => $url                       || undef,
                digest     => Digest::MD5::md5_hex($url) || undef,
            },
            { key => 'unique_url' }
        ) if !$obj;
        $self->log->info( 'Create thumbnail ' . $obj->id );

        # make thumbnails
        $self->timer->set_mark('t2');
        $self->create_img( path => $self->tmpfile_path, width => ORIGINAL_WIDTH, height => ORIGINAL_HEIGHT );
#        $self->write_thumbnail( path => $obj->original_path, width => ORIGINAL_WIDTH, height => ORIGINAL_HEIGHT );
        $self->write_thumbnail( path => $obj->large_path,    width => LARGE_WIDTH,    height => LARGE_HEIGHT    );
        $self->write_thumbnail( path => $obj->medium_path,   width => MEDIUM_WIDTH,   height => MEDIUM_HEIGHT   );
        $self->write_thumbnail( path => $obj->small_path,    width => SMALL_WIDTH,    height => SMALL_HEIGHT    );
        $self->timer->set_mark('t3');
        $self->log->debug(
            sprintf 'Took %.5f seconds to write thumbnails',
            $self->timer->get_diff_time( 't2', 't3' )
        );

        $self->unlink_tmpfile;
        $self->saycheese_free;
        $self->timer->stop;
        $self->log->info( sprintf 'Took %.5f seconds',
            $self->timer->get_total_time );

        # return thumbnail id, or FAILURE(0)
        my $ret = undef;
        if ($obj) {
            $obj->is_finished(1);
            $obj->update;
            $self->log->info("Finish to saycheese\n\n");
            $ret = $obj->id;
        }
        else {
            $self->log->error("Finish to saycheese\n\n");
            $ret = FAILURE;
        }

        $self->log->_flush;
        return $ret;
    }
}

=head2 tmpfile

=cut

sub tmpfile {
    my $self = shift;

    if ( defined $self->tmpfile ) {
        return $self->tmpfile;
    }
    else {
        $self->tmpfile = sprintf q{%d-%d.%s}, time, $$,
            $self->config->{thumbnail}->{extension};
        return $self->tmpfile;
    }
}

=head2 tmpfile_path

=cut

sub tmpfile_path { sprintf q{/tmp/%s}, shift->tmpfile }

=head2 unlink_tmpfile

=cut

sub unlink_tmpfile {
    my $self = shift;

    $self->log->info( 'Unlink tmp file ' . $self->tmpfile_path );
    unlink $self->tmpfile_path
        or $self->log->error( "Can't unlink tmpfile " . $self->tmpfile_path );
}

=head2 wait

=cut

sub wait {
    my $self = shift;

    sleep $self->interval;
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
    $self->log->info("Execute command $cmd");

    return system $cmd;
}
 
=head2 create_img

=cut

sub create_img {
    my ( $self, %args ) = @_;

    $args{quality} ||= 100;
    $self->image->Read( $args{path} );
    $self->image->Set( quality => $args{quality} );
    $self->image->Crop(
        width  => $args{width},
        height => $args{height},
        x      => 7,
        y      => 116
    );
}

sub write_thumbnail {
    my ( $self, %args ) = @_;

    my $clone = $self->image->Clone;
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
    $self->image(undef);
    $self->tmpfile(undef);
}

1;

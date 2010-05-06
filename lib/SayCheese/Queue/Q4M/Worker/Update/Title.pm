package SayCheese::Queue::Q4M::Worker::Update::Title;

use Moose;
use SayCheese::API::Thumbnail;
use namespace::autoclean;

extends 'SayCheese::Queue::Q4M::Worker';

has _thumbnail => (
    is       => 'ro',
    isa      => 'SayCheese::API::Thumbnail',
    required => 1,
    lazy     => 1,
    builder  => '_build_thumbnail',
);

sub _build_thumbnail { SayCheese::API::Thumbnail->new }

__PACKAGE__->meta->make_immutable;

sub _work {
    my $self = shift;

    my $res = $self->next;
    return $self->end if !$res->as_bool;

    $self->timer->start;
    $self->log->info( sprintf 'Queue found in %s', $res->as_string );

    my $q     = $self->dequeue_hashref;
    my $url   = $q->{url};
    my $title = $q->{title};

    $self->timer->set_mark('t0');
    my $thumb = $self->_thumbnail->find_by_url($url);
    $self->timer->set_mark('t1');
    $self->log->debug(
        sprintf 'Took %.5f seconds to fetch the thumbnail',
        $self->timer->get_diff_time( 't0', 't1' )
    );

    if ( !$thumb ) {
        $self->log->warn( sprintf 'No thumbnail found %s', $url );
        return $self->end;
    }

    $self->timer->set_mark('t2');
    $thumb->title($title);
    $thumb->update;
    $self->timer->set_mark('t3');
    $self->log->debug( sprintf 'Took %.5f seconds to update title %s',
        $self->timer->get_diff_time( 't2', 't3' ), $title );

    $self->end;
    $self->log->info( sprintf 'Took %.5f seconds',
        $self->timer->get_total_time );
}

1;

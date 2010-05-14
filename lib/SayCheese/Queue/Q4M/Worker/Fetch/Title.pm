package SayCheese::Queue::Q4M::Worker::Fetch::Title;

use Moose;
use SayCheese::HTML::Parser;
use SayCheese::UserAgent;
use SayCheese::Queue::Q4M::Worker::Update::Title;
use namespace::autoclean;

extends 'SayCheese::Queue::Q4M::Worker';

__PACKAGE__->meta->make_immutable;

sub _work {
    my $self = shift;

    my $updater = SayCheese::Queue::Q4M::Worker::Update::Title->new;
    my $parser  = SayCheese::HTML::Parser->new;
    my $res     = $self->next(
        [ 'status_code = 0', 'status_code = 0', 'status_code = 0' ] );
    return $self->end if !$res->as_bool;

    $self->timer->start;
    $self->log->info( sprintf 'Queue found in %s', $res->as_string );

    my $q   = $self->dequeue_hashref;
    my $url = $q->{url};

    $self->log->info( sprintf 'Fetching document %s', $url );
    $self->timer->set_mark('t0');
    $parser->parse($url);
    $self->timer->set_mark('t1');
    $self->log->debug(
        sprintf 'Took %.5f seconds to fetch the document',
        $self->timer->get_diff_time( 't0', 't1' )
    );

    $self->timer->set_mark('t2');
    my $title = $parser->title;
    $self->timer->set_mark('t3');
    $self->log->debug( sprintf 'Took %.5f seconds to parse title %s',
        $self->timer->get_diff_time( 't2', 't3' ), $title );

    if ( !$title ) {
        $self->log->warn( sprintf "Can't fetch the title %s", $url );
        return $self->end;
    }

    $self->timer->set_mark('t4');
    $updater->enqueue(
        'update_title20',
        {
            created_on => undef,
            url        => $url || undef,
            title      => $title || undef,
        }
    );
    $self->timer->set_mark('t5');
    $self->log->debug(
        sprintf 'Took %.5f seconds to queue in update_title',
        $self->timer->get_diff_time( 't4', 't5' )
    );

    $self->end;
    $self->log->info( sprintf 'Took %.5f seconds',
        $self->timer->get_total_time );
}

1;

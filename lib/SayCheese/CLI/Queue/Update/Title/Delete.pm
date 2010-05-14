package SayCheese::CLI::Queue::Update::Title::Delete;

use Moose;
use namespace::autoclean;

has status => (
    is            => 'ro',
    isa           => 'Int',
    required      => 0,
    documentation => 'The number of HTTP status code to be deleted',
);

with 'MooseX::Getopt';
with 'SayCheese::CLI::Queue::Update::Title';

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    while (
        my $res = $self->_update_title->next(
            [
                'status = ' . $self->status,
                'status = ' . $self->status,
                'status = ' . $self->status,
            ],
            $self->timeout
        )
        )
    {
        my $q = $self->_update_title->dequeue_hashref;
        $self->_log->fdebug( $q->{url} );
        $self->_update_ttle->end;
    }
}

1;

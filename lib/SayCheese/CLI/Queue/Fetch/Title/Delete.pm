package SayCheese::CLI::Queue::Fetch::Title::Delete;

use Moose;
use namespace::autoclean;

has status_code => (
    is            => 'ro',
    isa           => 'Int',
    required      => 1,
    documentation => 'The number of HTTP status code to be deleted',
);

with 'MooseX::Getopt';
with 'SayCheese::CLI::Queue::Fetch::Title';

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    while (
        my $res = $self->_fetch_title->next(
            [
                'status_code = ' . $self->status_code,
                'status_code = ' . $self->status_code,
                'status_code = ' . $self->status_code
            ],
            $self->timeout
        )
        )
    {
        my $q = $self->_fetch_title->dequeue_hashref;
        $self->_log->fdebug($q->{url});
        $self->_fetch_ttle->end;
    }
}

1;

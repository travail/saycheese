package SayCheese::CLI::Queue::SayCheese::Reenqueue;

use Moose;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'SayCheese::CLI::Queue::SayCheese';

has 'table' => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    cmd_aliases   => [qw( t )],
    documentation => 'The table name where queue in',
);

has 'http_status' => (
    is            => 'ro',
    isa           => 'Int',
    required      => 1,
    documentation => 'The HTTP status code to be re-queued in',
);

has 'timeout' => (
    is            => 'ro',
    isa           => 'Int',
    default       => 1,
    required      => 0,
    documentation => 'The seconds to timeout of queue_wait()',
);

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    while (
        my $res = $self->_saycheese->next(
            [
                'http_status = ' . $self->http_status,
                'http_status = ' . $self->http_status,
                'http_status = ' . $self->http_status,
            ],
            $self->timeout
        )
        )
    {
        my $q = $self->_saycheese->dequeue_hashref;
        $self->_log->fdebug( $q->{url} );
        $q->{created_on}  = undef;
        $q->{http_status} = 0;
        $self->_saycheese->enqueue( $self->table, $q );
        $self->_saycheese->end;
    }
}

1;

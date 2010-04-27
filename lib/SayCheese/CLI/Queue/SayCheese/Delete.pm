package SayCheese::CLI::Queue::SayCheese::Delete;

use Moose;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'SayCheese::CLI::Queue::SayCheese';

has '+table' => (
    required => 0,
);

has 'http_status' => (
    is            => 'ro',
    isa           => 'Int',
    required      => 1,
    documentation => 'The HTTP status code to be deleted',
);

has 'rows' => (
    is            => 'ro',
    isa           => 'Int',
    default       => 10,
    required      => 0,
    documentation => 'The number of records to be retrieved',
);

has 'timeout' => (
    is            => 'ro',
    isa           => 'Int',
    default       => 3,
    required      => 0,
    documentation => 'The seconds to timeout of queue_wait()',
);

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
        $self->_log->fdebug( 'Queue found in ' . $res->as_string );
        $self->_log->fdebug( $q->{url} );
        $self->_saycheese->end;
    }
}

1;

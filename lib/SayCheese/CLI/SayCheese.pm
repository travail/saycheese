package SayCheese::CLI::SayCheese;

use Moose;
use SayCheese::Queue::Worker::SayCheese;
use namespace::autoclean;

with 'MooseX::Getopt';

has 'max_workers' => (
    is            => 'ro',
    isa           => 'Int',
    default       => '1',
    required      => 1,
    documentation => 'The number of processes to be forked',
);

has 'timeout' => (
    is            => 'ro',
    isa           => 'Int',
    default       => 300,
    required      => 0,
    documentation => 'The seconds to timeout of queue_wait()',
);

has 'debug' => (
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
    required      => 0,
    cmd_aliases   => [qw( d )],
    documentation => 'Run the daemon under the debug mode',
);

has 'help' => (
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
    required      => 0,
    cmd_aliases   => [qw( h )],
    documentation => 'Show this helps',
);

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    SayCheese::Queue::Worker::SayCheese->new(
        {
            max_workers => $self->max_workers,
            timeout     => $self->timeout,
            debug       => $self->debug,
        }
    )->work;
}

1;

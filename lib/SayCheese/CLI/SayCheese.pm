package SayCheese::CLI::SayCheese;

use Moose;
use Pod::Usage ();
use SayCheese::Queue::Worker::SayCheese;
use namespace::autoclean;

with 'MooseX::Getopt';

has 'max_workers' => (
    is            => 'rw',
    isa           => 'Int',
    default       => 1,
    required      => 1,
    documentation => 'The number of workers to be forked',
);

has 'debug' => (
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    is            => 'rw',
    isa           => 'Bool',
    cmd_aliases   => [qw( d )],
    required      => 0,
    documentation => 'Run the script under debug mode',
);

has 'help' => (
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    is            => 'rw',
    isa           => 'Bool',
    cmd_aliases   => [qw( h )],
    required      => 0,
    documentation => 'Show this messages',
);

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    my $worker = SayCheese::Queue::Worker::SayCheese->new({
        max_workers => $self->max_workers,
        debug       => $self->debug,
    });

    $worker->work;
}

1;

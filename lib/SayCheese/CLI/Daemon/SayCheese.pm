package SayCheese::CLI::Daemon::SayCheese;

use Moose;
use SayCheese::Queue::Q4M::Worker::SayCheese;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'SayCheese::CLI::Daemon';

has interval => (
    is       => 'rw',
    isa      => 'Int',
    required => 0,
);

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    SayCheese::Queue::Q4M::Worker::SayCheese->new(
        {
            max_workers => $self->max_workers,
            timeout     => $self->timeout,
            interval    => $self->interval,
            debug       => $self->debug,
        }
    )->work;
}

1;

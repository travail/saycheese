package SayCheese::CLI::Daemon::SayCheese;

use Moose;
use SayCheese::Queue::Q4M::Worker::SayCheese;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'SayCheese::CLI::Daemon';

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

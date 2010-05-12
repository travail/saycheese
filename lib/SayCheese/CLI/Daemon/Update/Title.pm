package SayCheese::CLI::Daemon::Update::Title;

use Moose;
use SayCheese::Queue::Q4M::Worker::Update::Title;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'SayCheese::CLI::Daemon';

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    SayCheese::Queue::Q4M::Worker::Update::Title->new(
        {
            max_workers => $self->max_workers,
            timeout     => $self->timeout,
        }
    )->work;
}

1;

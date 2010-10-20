package SayCheese::CLI::Daemon::SayCheese;

use Moose;
use SayCheese::Queue::Q4M::Worker::SayCheese;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'SayCheese::CLI::Daemon';

has ua_timeout => (
    is            => 'rw',
    isa           => 'NaturalNumber',
    documentation => 'The number of seconds to timeout for user agent',
);

has interval => (
    is            => 'rw',
    isa           => 'NaturalNumber',
    documentation => 'The number of seconds to wait to get the next page',
);

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    SayCheese::Queue::Q4M::Worker::SayCheese->new(
        {
            max_workers => $self->max_workers,
            timeout     => $self->timeout,
            ua_timeout  => $self->ua_timeout,
            interval    => $self->interval,
            debug       => $self->debug,
        }
    )->work;
}

1;

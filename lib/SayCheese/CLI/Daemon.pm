package SayCheese::CLI::Daemon;

use Moose::Role;
use namespace::autoclean;

with 'MooseX::Getopt';

has max_workers => (
    is            => 'ro',
    isa           => 'Int',
    default       => 0,
    required      => 0,
    documentation => 'The number of processes to be forked',
);

has timeout => (
    is            => 'ro',
    isa           => 'Int',
    default       => 300,
    required      => 0,
    documentation => 'The number of senconds to timeout queue_wait()',
);

has debug => (
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
    required      => 0,
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    cmd_aliases   => [qw( d )],
    documentation => 'Run the script with debug mode',
);

has help => (
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
    required      => 0,
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    cmd_aliases   => [qw( h )],
    documentation => 'Show this help',
);

1;

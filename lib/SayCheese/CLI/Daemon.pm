package SayCheese::CLI::Daemon;

use Moose::Role;
use Moose::Util::TypeConstraints;
use SayCheese::Utils ();
use namespace::autoclean;

with 'MooseX::Getopt';

subtype 'NaturalNumber' => as 'Int' =>
    where { SayCheese::Utils::is_natural_number($_) };

has max_workers => (
    is            => 'ro',
    isa           => 'NaturalNumber',
    default       => 1,
    required      => 0,
    documentation => 'The number of processes to be forked',
);

has timeout => (
    is            => 'ro',
    isa           => 'NaturalNumber',
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

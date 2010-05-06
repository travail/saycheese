package SayCheese::CLI::Queue::Fetch::Title;

use Moose::Role;
use SayCheese::Log;
use SayCheese::Queue::Q4M::Worker::Fetch::Title;
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
    default       => 1,
    required      => 0,
    documentation => 'The number of seconds to timeout queue_wait()',
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
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    cmd_aliases   => [qw( h )],
    documentation => 'Show this help',
);

has _fetch_title => (
    is       => 'ro',
    isa      => 'SayCheese::Queue::Q4M::Worker::Fetch::Title',
    required => 1,
    lazy     => 1,
    builder  => '_build_fetch_title',
);

has '_log' => (
    is       => 'ro',
    isa      => 'SayCheese::Log',
    required => 1,
    lazy     => 1,
    builder  => '_build_log',
);

sub _build_fetch_title { SayCheese::Queue::Q4M::Worker::Fetch::Title->new }
sub _build_log         { SayCheese::Log->new }

1;

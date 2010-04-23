package SayCheese::CLI::Queue::SayCheese;

use Moose::Role;
use SayCheese::API::Thumbnail;
use SayCheese::Log;
use SayCheese::Queue::Worker::SayCheese;
use namespace::autoclean;

with 'MooseX::Getopt';

has 'table' => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    cmd_aliases   => [qw( t )],
    documentation => 'The table name where queue in',
);

has 'debug' => (
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
    required      => 0,
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    cmd_aliases   => [qw( d )],
    documentation => 'Run the script with debug mode',
);

has 'help' => (
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    cmd_aliases   => [qw( h )],
    documentation => 'Show this help',
);

has '_saycheese' => (
    is       => 'ro',
    isa      => 'SayCheese::Queue::Worker::SayCheese',
    required => 1,
    lazy     => 1,
    builder  => '_build_saycheese',
);

has '_thumbnail' => (
    is       => 'ro',
    isa      => 'SayCheese::API::Thumbnail',
    required => 1,
    lazy     => 1,
    builder  => '_build_thumbnail',
);

has '_log' => (
    is       => 'ro',
    isa      => 'SayCheese::Log',
    required => 1,
    lazy     => 1,
    builder  => '_build_log',
);

sub _build_saycheese { SayCheese::Queue::Worker::SayCheese->new }
sub _build_thumbnail { SayCheese::API::Thumbnail->new }
sub _build_log       { SayCheese::Log->new }

1;

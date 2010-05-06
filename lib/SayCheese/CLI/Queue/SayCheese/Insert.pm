package SayCheese::CLI::Queue::SayCheese::Insert;

use Moose;
use namespace::autoclean;

with 'MooseX::Getopt';
with 'SayCheese::CLI::Queue::SayCheese';

has 'table' => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    cmd_aliases   => [qw( t )],
    documentation => 'The table name where queue in',
);

has 'is_finished' => (
    is            => 'ro',
    isa           => 'Int',
    required      => 1,
    documentation => 'The number of is_finished to be retrieved',
);

has 'rows' => (
    is            => 'ro',
    isa           => 'Int',
    default       => 10,
    required      => 0,
    documentation => 'The number of records to be retrieved',
);

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    my $iter
        = $self->_thumbnail->search( { is_finished => $self->is_finished },
        { rows => $self->rows } );

    while ( my $obj = $iter->next ) {
        my $url = $obj->url->as_string;
        $self->_saycheese->enqueue(
            $self->table,
            {
                created_on => undef,
                url        => $url,
            }
        );
        $self->_log->fdebug($url) if $self->debug;
    }
}

1;

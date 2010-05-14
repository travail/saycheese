package SayCheese::CLI::Queue::Fetch::Title::Enqueue;

use Moose;
use SayCheese::API::Thumbnail;
use namespace::autoclean;

has table => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    documentation => 'The table name where queue in',
);

has is_finished => (
    is            => 'ro',
    isa           => 'Int',
    required      => 1,
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    cmd_aliases   => [qw( F )],
    documentation => 'The number of is_finished to be queued in',
);

has rows => (
    is            => 'ro',
    isa           => 'Int',
    default       => 100,
    required      => 0,
    documentation => 'The number of rows to be retrieved from thumbnail',
);

has _thumbnail => (
    is       => 'ro',
    isa      => 'SayCheese::API::Thumbnail',
    required => 1,
    lazy     => 1,
    builder  => '_build_thumbnail',
);

sub _build_thumbnail { SayCheese::API::Thumbnail->new }

with 'MooseX::Getopt';
with 'SayCheese::CLI::Queue::Fetch::Title';

__PACKAGE__->meta->make_immutable;

sub run {
    my $self = shift;

    my $iter_thumb
        = $self->_thumbnail->search( { is_finished => $self->is_finished },
        { rows => $self->rows } );
    while ( my $thumb = $iter_thumb->next ) {
        my $url = $thumb->url->as_string;
        $self->_fetch_title->enqueue(
            $self->table,
            {
                created_on => undef,
                url        => $url || undef,
            }
        );
        $self->_log->fdebug($url);
    }
}

1;

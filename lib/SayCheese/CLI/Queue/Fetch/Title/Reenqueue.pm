package SayCheese::CLI::Queue::Fetch::Title::Reenqueue;

use Moose;
use SayCheese::API::Thumbnail;
use namespace::autoclean;

has table => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    documentation => 'The table name where queue in',
);

has status_code => (
    is            => 'ro',
    isa           => 'Int',
    required      => 1,
    metaclass     => 'MooseX::Getopt::Meta::Attribute',
    documentation => 'The number of HTTP status code to be queued in',
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

    while (
        my $res = $self->next(
            [
                'status_code = ' . $self->status_code,
                'status_code = ' . $self->status_code,
                'status_code = ' . $self->status_code,
            ],
            $self->timeout
        )
        )
    {
        my $q   = $self->dequeue_hashref;
        my $url = $q->{url};
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

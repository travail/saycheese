package SayCheese::API::Thumbnail;

use Moose;
use SayCheese::Config;

has 'moniker' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'Thumbnail',
);

with 'SayCheese::API::DBIC::Schema';

=head1 NAME

SayCheese::API::Thumbnail -

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 find_by_url

=cut

sub find_by_url { shift->single( { url => shift } ) }

=head2 find_by_url_like

=cut

sub find_by_url_like {
    my ( $self, $url ) = @_;

    return $self->single( { url => { LIKE => sprintf q{%s%%}, $url } } );
}

=head2 index_thumbnails

=cut

sub index_thumbnails {
    my ( $self, $cond, $attrs ) = @_;

    my %wheres = ();
    $wheres{url} = { LIKE => sprintf q{%s%%}, $cond->{url} } if $cond->{url};
    return $self->search(
        {%wheres},
        {
            order_by => 'id DESC',
            rows     => $attrs->{rows} || 20,
            page     => $attrs->{page} || 1,
        },
    );
}

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#__PACKAGE__->meta->make_immutable;

package SayCheese::Schema::Thumbnail;

use strict;
use warnings;
use base 'DBIx::Class';
use SayCheese;
use SayCheese::Utils qw/ url2thumbpath /;

__PACKAGE__->load_components( qw/ PK::Auto ResultSetManager +SayCheese::DBIC Core / );
__PACKAGE__->table('thumbnail');
__PACKAGE__->add_columns( qw/
    id
    created_on
    modified_on
    url
    digest
    is_finished
/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( unique_url => [ qw/ url / ] );
__PACKAGE__->datetime_column( qw/ created_on modified_on / );

=head1 NAME

SayCheese::Schema::Thumbnail

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=head2 as_hashref

=cut

sub as_hashref {
    my $self = shift;

    my $config = SayCheese->config;
    return {
        id          => $self->id,
        created_on  => sprintf( q{%s %s}, $self->created_on->ymd, $self->created_on->hms ),
        modified_on => sprintf( q{%s %s}, $self->modified_on->ymd, $self->modified_on->hms ),
        url         => $self->url,
        digest      => $self->digest,
        extension   => $config->{thumbnail}->{extension},
    };
}

=head2 index_thumbnails

=cut

sub index_thumbnails : ResultSet {
    my ( $class, %args ) = @_;

    my $config = SayCheese->config;
    my %wheres = ();
    $wheres{url} = { LIKE => sprintf q{%s%%}, $args{url} } if $args{url};
    return $class->search(
        { %wheres },
        {
            order_by => 'id DESC',
            rows     => $args{rows} || $config->{default_rows},
            page     => $args{page} || 1,
        },
    );
}

=head2 find_by_url

=cut

sub find_by_url : ResultSet {
    my ( $class, $url ) = @_;

    return $class->single( { url => $url } );
}

=head2 find_by_url_like

=cut

sub find_by_url_like : ResultSet {
    my ( $class, $url ) = @_;

    return $class->single( { url => { LIKE => sprintf q{%s%%}, $url } } );
}

=head2 original_path

Returns path to original size thumbnail.

=cut

sub original_path { url2thumbpath( shift->url, 'original' ) }

=head2 large_path

Returns path to large size thumbnail.

=cut

sub large_path { url2thumbpath( shift->url, 'large' ) }

=head2 medium_path

Returns path to medium size thumbnail.

=cut

sub medium_path { url2thumbpath( shift->url, 'medium' ) }

=head2 small_path

Returns path to small size thumbnail.

=cut

sub small_path { url2thumbpath( shift->url, 'small' ) }

=head1 AUTHOR

travail, C<travail@cabane.no-ip.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;





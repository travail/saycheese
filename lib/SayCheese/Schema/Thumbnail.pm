package SayCheese::Schema::Thumbnail;

use strict;
use warnings;
use base 'DBIx::Class';
use SayCheese::Config;
use SayCheese::Utils qw();

__PACKAGE__->load_components( qw(
    ResultSetManager
    InflateColumn::DateTime
    InflateColumn::URI
    Core
) );
__PACKAGE__->table('thumbnail');
__PACKAGE__->add_columns(
    'id',
    'created_on', { data_type => 'datetime' },
    'modified_on', { data_type => 'datetime' },
    'url', { data_type => 'varchar', is_uri => 1 },
    'digest',
    'is_finished',
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( unique_url => [ qw( url ) ] );

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

    my $config = SayCheese::Config->instance->config;
    my $created_on = sprintf q{%s %s}, $self->created_on->ymd,
        $self->created_on->hms;
    my $modified_on = sprintf q{%s %s}, $self->modified_on->ymd,
        $self->modified_on->hms;
    return {
        id          => $self->id                         || undef,
        created_on  => $created_on                       || undef,
        modified_on => $modified_on                      || undef,
        url         => $self->url                        || undef,
        digest      => $self->digest                     || undef,
        extension   => $config->{thumbnail}->{extension} || undef,
    };
}

=head2 index_thumbnails

=cut

sub index_thumbnails : ResultSet {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    my %wheres = ();
    $wheres{url} = { LIKE => sprintf q{%s%%}, $args{url} } if $args{url};
    return $class->search(
        {%wheres},
        {
            order_by => 'id DESC',
            rows     => $args{rows} || $config->{default_rows},
            page     => $args{page} || 1,
        },
    );
}

=head2 find_by_url

=cut

sub find_by_url : ResultSet { shift->single( { url => shift } ) }

=head2 find_by_url_like

=cut

sub find_by_url_like : ResultSet {
    my ( $class, $url ) = @_;

    return $class->single( { url => { LIKE => sprintf q{%s%%}, $url } } );
}

=head2 thumbnail_path

=cut

sub thumbnail_path {
    my ( $self, %args ) = @_;

    $args{size} ||= 'medium';
    my $method = $args{size} . '_path';

    return $self->$method;
}

=head2 original_path

Returns path to original size thumbnail.

=cut

sub original_path { SayCheese::Utils::url2thumbpath( shift->url, 'original' ) }

=head2 large_path

Returns path to large size thumbnail.

=cut

sub large_path { SayCheese::Utils::url2thumbpath( shift->url, 'large' ) }

=head2 medium_path

Returns path to medium size thumbnail.

=cut

sub medium_path { SayCheese::Utils::url2thumbpath( shift->url, 'medium' ) }

=head2 small_path

Returns path to small size thumbnail.

=cut

sub small_path { SayCheese::Utils::url2thumbpath( shift->url, 'small' ) }

=head1 AUTHOR

TRAVAIL

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

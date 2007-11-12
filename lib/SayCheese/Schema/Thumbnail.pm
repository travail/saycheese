package SayCheese::Schema::Thumbnail;

use strict;
use warnings;
use base 'DBIx::Class';
use SayCheese;
use IO::File;

__PACKAGE__->load_components( qw/ PK::Auto ResultSetManager +SayCheese::DBIC Core / );
__PACKAGE__->table('thumbnail');
__PACKAGE__->add_columns( qw/
    id
    created_on
    modified_on
    url
    thumbnail_name
    extension
    original
    large
    medium
    small
    is_finished
/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( unique_url => [ qw/ url / ] );
__PACKAGE__->datetime_column( qw/ created_on modified_on / );

sub as_hashref {
    my $self = shift;

    return {
        id             => $self->id,
        created_on     => sprintf( q{%s %s}, $self->created_on->ymd, $self->created_on->hms ),
        modified_on    => sprintf( q{%s %s}, $self->modified_on->ymd, $self->modified_on->hms ),
        url            => $self->url,
        thumbnail_name => $self->thumbnail_name,
        extension      => $self->extension,
    };
}

sub index_thumbnails : ResultSet {
    my ( $self, %args ) = @_;

    my $config = SayCheese->config;
    return $self->search(
        {},
        {
            order_by => 'id DESC',
            rows     => $args{rows} || $config->{default_rows},
            page     => $args{page} || 1,
        },
    );
}

sub find_by_url : ResultSet {
    my ( $self, $url ) = @_;

    return $self->single( { url => { LIKE => sprintf q{%s%%}, $url } }, {});
}

sub print_thumbnail {
    my $self = shift;

    my $config = SayCheese->config;
    my $fh = IO::File->new( $self->path, 'w' );
    $fh->print( $self->medium );
}

sub img_path {
    my $self = shift;

    $self->print_thumbnail unless -e $self->path;
    return sprintf q{static/thumbnail/%d.%s}, $self->id, $self->extension;
}

sub path {
    my $self = shift;

    my $config = SayCheese->config;
    return sprintf q{%s/%s.%s}, $config->{thumbnail}->{thumbnail_path}, $self->id, $self->extension;
}

sub file_name {
    my $self = shift;

    return sprintf q{%d.%s}, $self->id, $self->extension;
}

1;

package SayCheese::Schema::Thumbnail;

use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components( qw/ PK::Auto ResultSetManager +SayCheese::DBIC Core / );
__PACKAGE__->table('thumbnail');
__PACKAGE__->add_columns( qw/
    id
    created_on
    modified_on
    url
    thumbnail_name
    extention
    filedata
    width
    height
    filesize
/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->datetime_column( qw/ created_on modified_on / );

sub as_hashref {
    my $self = shift;

    return {
        id             => $self->id,
        created_on     => sprintf( q{%s %s}, $self->created_on->ymd, $self->created_on->hms ),
        modified_on    => sprintf( q{%s %s}, $self->modified_on->ymd, $self->modified_on->hms ),
        url            => $self->url,
        thumbnail_name => $self->thumbnail_name,
        extention      => $self->extention,
        width          => $self->width,
        height         => $self->height,
        filesize       => $self->filesize,
    };
}

sub find_by_url : ResultSet {
    my ( $self, $url ) = @_;

    return $self->single( { url => $url }, {});
}

sub img {
    my $self = shift;

    return sprintf q{<img class="thumbnails" src="/static/thumbnail/%d.%s">}, $self->id, $self->extention;
}

1;

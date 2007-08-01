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

sub index_thumbnails : ResultSet {
    my ( $self, %args ) = @_;

    return $self->search(
        {},
        {
            order_by => 'id DESC',
            rows     => $args{rows} || 5,
            page     => $args{page} || 1,
        },
    );
}

sub find_by_url : ResultSet {
    my ( $self, $url ) = @_;

    return $self->single( { url => $url }, {});
}

sub print_thumbnail {
    my $self = shift;

    my $config = SayCheese->config;
    my $fh = IO::File->new( $self->path, 'w' );
    $fh->print( $self->filedata );
}

sub path {
    my $self = shift;

    my $config = SayCheese->config;
    return sprintf q{%s/%s.%s}, $config->{thumbnail}->{thumbnail_path}, $self->id, $self->extention;
}

sub file_name {
    my $self = shift;

    return sprintf q{%d.%s}, $self->id, $self->extention;
}

1;

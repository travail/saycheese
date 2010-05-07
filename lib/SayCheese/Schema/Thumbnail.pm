package SayCheese::Schema::Thumbnail;

use strict;
use warnings;
use base 'DBIx::Class';
use SayCheese::Config;
use SayCheese::Queue::Q4M::Worker::Fetch::Title;
use SayCheese::Utils ();

__PACKAGE__->load_components( qw(
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
    'title',
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

=cut

sub insert {
    my $class = shift;

    my $self = $class->next::method(@_);
    $self->enqueue_fetch_title();

    return $self;
}

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

sub enqueue_fetch_title {
    my $self = shift;

    my $worker = SayCheese::Queue::Q4M::Worker::Fetch::Title->new;
    $worker->enqueue(
        'fetch_title20',
        {
            created_on => undef,
            url        => $self->url->as_string || undef,
        }
    );
}

=head1 AUTHOR

TRAVAIL

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

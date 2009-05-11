package SayCheese::API::DBIC::Schema;

use Carp::Clan qw();
use Moose::Role;
use SayCheese::Schema;
use SayCheese::Utils qw();

has 'moniker' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'schema' => (
    is      => 'ro',
    isa     => 'SayCheese::Schema',
    lazy    => 1,
    default => sub {
        my $schema = SayCheese::Schema->connect(SayCheese::Utils::connect_info);
        return $schema;
    },
);
no Moose::Role;

=head1 NAME

SayCheese::API::DBIC::Schema -

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 find

=cut

sub find {
    my ( $self, $pkey ) = @_;

    Carp::Clan::croak("No primary key specifled") if !$pkey;

    $self->schema->resultset( $self->moniker )->find($pkey);
}

=head2 single

=cut

sub single {
    my ( $self, $cond ) = @_;

    $self->schema->resultset( $self->moniker )->single($cond);
}

=head2 search

=cut

sub search {
    my ( $self, $cond, $attrs ) = @_;

    $self->schema->resultset( $self->moniker )->search( $cond, $attrs );
}

=head2 count

=cut

sub count {
    my ( $self, $cond ) = @_;

    $self->schema->resultset( $self->moniker )->count($cond);
}

=head2 create

=cut

sub create {
    my ( $self, $vals, $attrss ) = @_;

    $self->schema->resultset( $self->moniker )->create( $vals, $attrss );
}

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

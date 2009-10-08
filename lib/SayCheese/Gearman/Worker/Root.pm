package SayCheese::Gearman::Worker::Root;

use strict;
use warnings;
use base qw( Class::Accessor::Fast Class::Data::Inheritable );
use Time::HiRes qw();

__PACKAGE__->mk_classdata( functions => [] );

=head1 NAME

SayCheese::Gearman::WorkerRoot - SayCheese Worker

=head1 DESCRIPTION

SayCheese Worker

=head1 METHODS

=cut

=head2 on_work

=cut

sub on_work {}

=head2 start_benchmark

=cut

sub start_benchmark {
    my ( $self, $key ) = @_;

    my $t0 = Time::HiRes::gettimeofday;
    $self->{bm}->{$key} = $t0;

    return $t0;
}

=head2 finish_benchmark

=cut

sub finish_benchmark {
    my ( $self, $key ) = @_;

    my $t0  = $self->{bm}->{$key};
    my $t1  = Time::HiRes::gettimeofday;
    my $ret = Time::HiRes::tv_interval( [$t0], [$t1] );
    $self->reset_benchmark($key);

    return $ret;
}

=head2 reset_benchmark

=cut

sub reset_benchmark {
    my ( $self, $key ) = @_;

    $self->{bm}->{$key} = [];
}

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

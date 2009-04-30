package SayCheese::DateTime;

use strict;
use warnings;
use DateTime;
use SayCheese::Config;

=head1 NAME

SayCheese::DateTime - SayCheese DateTime

=head1 DESCRIPTION

SayCheese DateTime

=head1 METHODS

=cut

=head2 new

=cut

sub new {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    $args{time_zone} ||= $config->{time_zone};
    my $self = DateTime->new( %args );

    return $self;
}

=head2 now

=cut

sub now {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    $args{time_zone} ||= $config->{time_zone};
    my $self = DateTime->now( %args );

    return $self;
}

=head2 from_epoch

=cut

sub from_epoch {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    $args{time_zone} ||= $config->{time_zone};
    my $self = DateTime->from_epoch( %args );

    return $self;
}

=head2 today

=cut

sub today {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    $args{time_zone} ||= $config->{time_zone};
    my $self = DateTime->today( %args );

    return $self;
}

=head2 from_object

=cut

sub from_object {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    $args{time_zone} ||= $config->{time_zone};
    my $self = DateTime->from_object( %args );

    return $self;
}

=head2 last_day_of_month

=cut

sub last_day_of_month {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    $args{time_zone} ||= $config->{time_zone};
    my $self = DateTime->last_day_of_month( %args );

    return $self;
}

=head2 from_day_of_year

=cut

sub from_day_of_year {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    $args{time_zone} ||= $config->{time_zone};
    my $self = DateTime->from_day_of_year( %args );

    return $self;
}

=head1 AUTHOR

travail

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

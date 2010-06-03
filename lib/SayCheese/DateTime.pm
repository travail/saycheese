package SayCheese::DateTime;

use strict;
use warnings;
use DateTime;
use DateTime::Format::HTTP;
use DateTime::Format::MySQL;

use constant TIME_ZONE => 'Asia/Tokyo';

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

    $args{time_zone} ||= TIME_ZONE;
    my $self = DateTime->new( %args );

    return $self;
}

=head2 now

=cut

sub now {
    my ( $class, %args ) = @_;

    $args{time_zone} ||= TIME_ZONE;
    my $self = DateTime->now( %args );

    return $self;
}

=head2 from_epoch

=cut

sub from_epoch {
    my ( $class, %args ) = @_;

    $args{time_zone} ||= TIME_ZONE;
    my $self = DateTime->from_epoch( %args );

    return $self;
}

=head2 today

=cut

sub today {
    my ( $class, %args ) = @_;

    $args{time_zone} ||= TIME_ZONE;
    my $self = DateTime->today( %args );

    return $self;
}

=head2 from_object

=cut

sub from_object {
    my ( $class, %args ) = @_;

    $args{time_zone} ||= TIME_ZONE;
    my $self = DateTime->from_object( %args );

    return $self;
}

=head2 last_day_of_month

=cut

sub last_day_of_month {
    my ( $class, %args ) = @_;

    $args{time_zone} ||= TIME_ZONE;
    my $self = DateTime->last_day_of_month( %args );

    return $self;
}

=head2 from_day_of_year

=cut

sub from_day_of_year {
    my ( $class, %args ) = @_;

    $args{time_zone} ||= TIME_ZONE;
    my $self = DateTime->from_day_of_year( %args );

    return $self;
}

=head2 parse_http

=cut

sub parse_http {
    my ( $class, $str ) = @_;

    my $dt = DateTime::Format::HTTP->parse_datetime($str);

    return $dt;
}

=head2 format_http

=cut

sub format_http {
    my ( $class, $dt ) = @_;

    my $str = DateTime::Format::HTTP->format_datetime($dt);

    return $str;
}

=head2 parse_mysql

=cut

sub parse_mysql {
    my ( $class, $str ) = @_;

    $str =~ s{T}{ };
    my $dt = DateTime::Format::MySQL->parse_datetime($str);

    return $dt;
}

=head2 format_mysql

=cut

sub format_mysql {
    my ( $class, $dt ) = @_;

    my $str = DateTime::Format::MySQL->format_datetime($dt);

    return $str;
}

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

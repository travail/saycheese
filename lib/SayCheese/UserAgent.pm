package SayCheese::UserAgent;

use strict;
use warnings;
use LWP::UserAgent;
use SayCheese::Config;

sub new {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    my $self = LWP::UserAgent->new(
        agent   => $args{agent}   || $config->{user_agent}->{agent},
        from    => $args{from}    || $config->{user_agent}->{from},
        timeout => $args{timeout} || $config->{user_agent}->{timeout},
    );
    $self->default_header( Accept => [ qw(text/html text/plain image/*) ] );

    return $self;
}

=head1 NAME

SayCheese::UserAgent - SayCheese UserAgent

=head1 DESCRIPTION

SayCheese UserAgent

=head1 METHODS

=cut

=head2 new

=cut

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

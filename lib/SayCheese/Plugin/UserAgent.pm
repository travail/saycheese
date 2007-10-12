package SayCheese::Plugin::UserAgent;

use strict;
use warnings;
use LWP::UserAgent;


=head1 NAME

SayCheese::Plugin::UserAgent - SayCheese User Agent

=head1 DESCRIPTION

SayCheese Plugin.

=head1 METHODS

=cut


=head2 user_agent

=cut

sub user_agent {
    my $c = shift;

    my $ua = LWP::UserAgent->new(
        agent   => $c->config->{user_agent}->{agent},
        from    => $c->config->{user_agent}->{from},
        timeout => $c->config->{user_agent}->{timeout},
    );
    $ua->default_header( Accept => [ qw(text/html text/plain image/*) ] );

    return $ua;
}


=head2 ua

=cut

*ua = \&user_agent;

=head1 AUTHOR

travail

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

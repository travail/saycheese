package SayCheese::Gearman::Client;

use strict;
use warnings;
use base 'Gearman::Client';
use SayCheese::Config;

=head1 NAME

SayCheese::Gearman::Client - SayCheese Gearman Client

=head1 DESCRIPTION

SayCheese Gearman Client

=head1 METHODS

=cut


=head2 new

=cut

sub new {
    my ( $class, %args ) = @_;

    my $config = SayCheese::Config->instance->config;
    $args{job_servers} ||= $config->{job_servers};
    my $self = $class->SUPER::new( %args );

    return $self;
}


=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

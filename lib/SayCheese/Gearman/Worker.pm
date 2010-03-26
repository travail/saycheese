package SayCheese::Gearman::Worker;

use strict;
use warnings;
use Carp::Clan qw();
use Gearman::Worker;
use Storable qw();
use UNIVERSAL::require;

=head1 NAME

SayCheese::Worker - SayCheese Worker

=head1 DESCRIPTION

SayCheese Worker

=head1 METHODS

=cut


=head2 new

=cut

sub new {
    my ( $class, %args ) = @_;

    Carp::Clan::croak("No 'worker_class' specified") if !$args{worker_class};
    my $self  = bless {
        worker_class => $args{worker_class},
        worker       => undef,
    }, $class;
    $self->_create_worker;

    return $self;
}

=head2 work

=cut

sub work {
    my $self = shift;

    my $worker
        = Gearman::Worker->new( job_servers => $self->config->{job_servers} );
    foreach my $func ( @{ $self->{worker}->functions } ) {
        $worker->register_function(
            $func => sub { $self->{worker}->$func(shift) } );
    }

    while (1) {
        $self->{worker}->on_work;
        $worker->work;
    }
}

=head2 config

=cut

sub config { ref $_[0]->{worker} ? $_[0]->{worker}->config : undef }

=head2 _create_worker

=cut

sub _create_worker {
    my $self = shift;

    my $worker_class = sprintf q{%s::%s}, ref $self, $self->{worker_class};
    $worker_class->require;
    Carp::Clan::croak $@ if $@;

    $self->{worker} = $worker_class->new;
}

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

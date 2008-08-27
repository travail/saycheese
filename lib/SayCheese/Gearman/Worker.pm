package SayCheese::Gearman::Worker;

use strict;
use warnings;
use Carp qw//;
use Gearman::Worker;

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

    Carp::croak "worker is required.\n" unless $args{worker_class};
    my $self = bless {
        _worker_class => $args{worker_class},
        _worker       => undef,
    }, $class;
    $self->_create_worker;

    return $self;
}

=head2 work

=cut

sub work {
    my $self = shift;

    my $worker = Gearman::Worker->new( job_servers => $self->{_worker}->config->{job_servers} );
    my $functions = $self->{_worker}->functions;
    foreach my $function ( @{$functions} ) {
        $worker->register_function( $function => sub { $self->{_worker}->$function( shift ) } );
    }

    $worker->work while 1;
}

=head2 create_worker

=cut

sub _create_worker {
    my $self = shift;

    my $worker_class = sprintf q{%s::%s}, ref $self, $self->{_worker_class};
    eval "require $worker_class";
    $self->{_worker} = $worker_class->new;
}


=head1 AUTHOR

travail

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

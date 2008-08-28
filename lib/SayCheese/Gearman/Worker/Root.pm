package SayCheese::Gearman::Worker::Root;

use strict;
use warnings;
use base qw/ Class::Accessor::Fast Class::Data::Inheritable /;

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


=head1 AUTHOR

travail

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

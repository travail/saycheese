package SayCheese::Schema;

use strict;
use base qw/ DBIx::Class::Schema /;

#__PACKAGE__->load_components( qw/ Slave / );
#__PACKAGE__->slave_datasource( [
#    [ qw/ dbi:mysql:saycheese_local:hostname=192.168.1.1 travail travail / ],
#    [ qw/ dbi:mysql:saycheese_local:hostname=192.168.1.2 travail travail / ],
#] );

=head1 NAME

SayCheese::Schema - The SayCheese Schema

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=head2 load_classes

=cut

__PACKAGE__->load_classes;

=head1 AUTHOR

travail, C<travail@cabane.no-ip.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

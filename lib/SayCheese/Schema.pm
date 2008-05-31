package SayCheese::Schema;

use strict;
use warnings;
use base qw/ DBIx::Class::Schema /;

#__PACKAGE__->load_components( qw/ Schema::Slave / );
#__PACKAGE__->slave_moniker('::Slave');
#__PACKAGE__->slave_connect_info( SayCheese->config->{slave_connect_info} );
#__PACKAGE__->loader_options(
#    relationships => 1,
#    components    => [ qw/
#        InflateColumn::DateTime
#        InflateColumn::URI
#        Row::Slave
#        Core
#    / ],
#);
__PACKAGE__->load_classes;

=head1 NAME

SayCheese::Schema - The SayCheese Schema

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS


=head1 AUTHOR

travail, C<travail@travail.jp>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

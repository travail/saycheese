package SayCheese::Schema::Member;

use strict;
use warnings;
use base 'DBIx::Class';
use SayCheese::Config;
use SayCheese::Utils qw();

__PACKAGE__->load_components( qw(
    InflateColumn::DateTime
    Core
) );
__PACKAGE__->table('member');
__PACKAGE__->add_columns(
    'id',
    'created_on', { data_type => 'datetime' },
    'modified_on', { data_type => 'datetime' },
    'member_id',
    'password',
    'email',
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( unique_member_id => [ qw( member_id ) ] );

=head1 NAME

SayCheese::Schema::Member

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=head2 foo

Foo

=cut

sub foo {}

=head1 AUTHOR

TRAVAIL

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

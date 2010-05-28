package SayCheese::Schema::Member;

use strict;
use warnings;
use base 'DBIx::Class';
use SayCheese::Config;
use SayCheese::Utils qw();

__PACKAGE__->load_components( qw(
    TimeStamp
    InflateColumn::DateTime
    Core
) );
__PACKAGE__->table('member');
__PACKAGE__->add_columns(
    'id',
    'created_on', { data_type => 'datetime', set_on_create => 1 },
    'modified_on', { data_type => 'datetime' },
    'member_id',
    'password',
    'email',
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( unique_member_id => [ qw( member_id ) ] );

sub get_timestamp { SayCheese::DateTime->now }

=head1 NAME

SayCheese::Schema::Member

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=head1 AUTHOR

TRAVAIL

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

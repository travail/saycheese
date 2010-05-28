package SayCheese::API::Member;

use Moose;

with 'SayCheese::API::DBIC::Schema';

has '+moniker' => (
    default  => 'Member',
);

#__PACKAGE__->meta->make_immutable;

no Moose;

=head1 NAME

SayCheese::API::Member -

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

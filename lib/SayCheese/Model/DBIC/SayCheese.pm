package SayCheese::Model::DBIC::SayCheese;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'SayCheese::Schema',
    connect_info => [
        'dbi:mysql:saycheese',
        'travail',
        'travail',
        
    ],
);

=head1 NAME

SayCheese::Model::DBIC::SayCheese - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<SayCheese>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<SayCheese::Schema>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

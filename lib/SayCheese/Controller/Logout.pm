package SayCheese::Controller::Logout;

use Moose;
BEGIN { extends 'Catalyst::Controller' }
no Moose;

=head1 NAME

SayCheese::Controller::Logout - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->logout;
    $c->res->redirect( $c->uri_for('/') );
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

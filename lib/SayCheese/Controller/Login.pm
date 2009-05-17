package SayCheese::Controller::Login;

use Moose;
BEGIN { extends 'Catalyst::Controller' }
no Moose;

=head1 NAME

SayCheese::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 begin

=cut

sub begin : Private {
    my ( $self, $c ) = @_;

    $c->log->info('*** SayCheese::Controller::Login::begin ***');
    $c->res->redirect( $c->uri_for('/') ) if $c->user_exists;
}

=head2 index

=cut

sub index : Path : Args(0) {}

=head2 index

=cut

sub authenticate : Path('authenticate') : Args(0) {
    my ( $self, $c ) = @_;

    my ( $member_id, $password )
        = ( $c->req->param('member_id'), $c->req->param('password') );
    if ( $member_id && $password ) {
        if ( $c->forward( '_authenticate', [ $member_id, $password ] ) ) {
            $c->res->redirect( $c->uri_for('/') );
        }
        else {
            $c->load_template('login/index.tt');
            $c->forward('index');
        }
    }
    else {
        $c->load_template('login/index.tt');
        $c->forward('index');
    }
}

=head2 _authenticate

=cut

sub _authenticate : Path : Args(2) {
    my ( $self, $c, $member_id, $password ) = @_;

    return $c->authenticate(
        { member_id => $member_id, password => $password } );
}

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

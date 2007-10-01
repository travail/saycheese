package SayCheese::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

SayCheese::Controller::Root - Root Controller for SayCheese

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    my $req = $c->req;
    my $itr_thumbnail = $c->thumbnail->index_thumbnails(
        rows => $req->param('rows') || 5,
        page => $req->param('page') || 1,
    );

    $c->stash->{itr_thumbnail} = $itr_thumbnail;
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    return if $c->res->status =~ /^3\d\d$/;
    return if $c->stash->{only_json};
    return if $c->stash->{only_file};

    $c->stash->{template} = $c->action->reverse . '.tt' unless $c->stash->{template};
    $c->forward('View::TT');
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

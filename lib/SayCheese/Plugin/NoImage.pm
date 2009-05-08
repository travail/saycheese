package SayCheese::Plugin::NoImage;

use strict;
use warnings;
use base 'Class::Data::Inheritable';
use SayCheese::FileHandle;

__PACKAGE__->mk_classdata('_large');
__PACKAGE__->mk_classdata('_medium');
__PACKAGE__->mk_classdata('_small');


=head1 NAME

SayCheese::Plugin::NoImage - SayCheese NoImage

=head1 DESCRIPTION

SayCheese Plugin.

=head1 METHODS

=cut


=head2 setup

=cut

sub setup {
    my $c = shift;

    my $config = $c->config;
    my ( $lfh, $mfh, $sfh );
#    $lfh = SayCheese::FileHandle->new( $config->{no_image}->{large}, 'r' );
    $mfh = SayCheese::FileHandle->new( $config->{no_image}->{medium}, 'r' );
    $sfh = SayCheese::FileHandle->new( $config->{no_image}->{small}, 'r' );

    my ( $ldata, $mdata, $sdata );
#    $ldata .= $lfh->slurp;
    $mdata .= $mfh->slurp;
    $sdata .= $sfh->slurp;

#    __PACKAGE__->_large( $ldata );
    __PACKAGE__->_medium( $mdata );
    __PACKAGE__->_small( $sdata );

    $c->next::method( @_ );
}

=head2 no_image

Returns no image. Default size is 'medium'.

=cut

sub no_image {
    my ( $c, $size ) = @_;

    $size ||= 'medium';
    $c->$size;
}

=head2 large

Returns large size no image.

=cut

sub large { shift->_large }

=head2 medium

Returns medium size no image.

=cut

sub medium { shift->_medium }

=head2 small

Returns small size no image.

=cut

sub small { shift->_small }


=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

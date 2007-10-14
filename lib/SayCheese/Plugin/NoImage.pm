package SayCheese::Plugin::NoImage;

use strict;
use warnings;
use base 'Class::Data::Inheritable';
use FileHandle;

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
#    my $large  = FileHandle->new( $config->{no_image}->{large}, 'r' );
    my $medium = FileHandle->new( $config->{no_image}->{medium}, 'r' );
    my $small  = FileHandle->new( $config->{no_image}->{small}, 'r' );

    my ( $l_data, $m_data, $s_data );
#    $l_data .= $_ while <$large>;
    $m_data .= $_ while <$medium>;
    $s_data .= $_ while <$small>;

#    __PACKAGE__->_large( $l_data );
    __PACKAGE__->_medium( $m_data );
    __PACKAGE__->_small( $s_data );

    $c->NEXT::setup( @_ );
}


=head2 no_image_l

=cut

sub no_image_l { __PACKAGE__->_large }


=head2 no_image_m

=cut

sub no_image_m { __PACKAGE__->_medium }


=head2 no_image_s

=cut

sub no_image_s { __PACKAGE__->_small }


=head1 AUTHOR

travail

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

package SayCheese::Plugin::NoImage;

use strict;
use warnings;
use base 'Class::Data::Inheritable';
use FileHandle;
use IO::File;

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
#    $lfh = IO::File->new( $config->{no_image}->{large}, IO::File::O_RDONLY );
    $mfh = IO::File->new( $config->{no_image}->{medium}, IO::File::O_RDONLY );
    $sfh = IO::File->new( $config->{no_image}->{small}, IO::File::O_RDONLY );

    my ( $ldata, $mdata, $sdata );
#    while ( $lfh->sysread( my $lbuf, 8192 ) ) {
#        $ldata .= $lbuf;
#    }

    while ( $mfh->sysread( my $mbuf, 8192 ) ) {
        $mdata .= $mbuf;
    }
    while ( $sfh->sysread( my $sbuf, 8192 ) ) {
        $sdata .= $sbuf;
    }

#    __PACKAGE__->_large( $ldata );
    __PACKAGE__->_medium( $mdata );
    __PACKAGE__->_small( $sdata );

    $c->NEXT::setup( @_ );
}

=head2 no_image_l

=cut

sub no_image_l { shift->_large }

=head2 no_image_m

=cut

sub no_image_m { shift->_medium }

=head2 no_image_s

=cut

sub no_image_s { shift->_small }


=head1 AUTHOR

travail

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

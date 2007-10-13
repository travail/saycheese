package SayCheese::Plugin::NoImage;

use strict;
use warnings;
use base 'Class::Data::Inheritable';
use FileHandle;

__PACKAGE__->mk_classdata( qw/ _large _medium _small / );


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

    foreach my $size ( qw/ large medium small / ) {
        my $data = undef;
        while ( <$size> ) {
            $data .= $_;
        }
        my $classdata = '_' . $size;
        __PACKAGE__->$classdata( $data );
    }

    $c->NEXT::setup( @_ );
}


=head1 AUTHOR

travail

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

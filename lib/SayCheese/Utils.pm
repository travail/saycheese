package SayCheese::Utils;

use strict;
use warnings;
use base qw/ Exporter /;
use FindBin qw/ $Bin /;
use File::Basename qw/ dirname /;
use File::Path qw/ mkpath /;
use File::Spec;
use Config::Multi;
use Digest::MD5 qw/ md5_hex /;

our @EXPORT_OK = ( qw/
    saycheese_config digest2thumbpath url2thumbpath unescape_uri
/ );

=head1 NAME

SayCheese::Utils - The SayCheese Utils

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=head2 saycheese_config

=cut
sub  saycheese_config {
    my ( $v, $d, $f ) = File::Spec->splitpath( $INC{'SayCheese/Utils.pm'} );
    my $dir = File::Spec->catfile( $d, '..', '..', 'etc', 'conf' );
    my $cm = Config::Multi->new( {
        dir       => $dir,
        app_name  => 'saycheese',
        prefix    => undef,
        extension => 'yml'
    } );
    return $cm->load;
}

=head2 digest2thumbpath( $digest, $size )

Return md5_hex file name from digest. Default size is medium.

=cut

sub digest2thumbpath {
    my ( $digest, $size ) = @_;

    return unless $digest;

    my $config = saycheese_config();
    $size ||= $config->{thumbnail}->{default_size};
    return sprintf q{%s/%s/%s/%s.%s},
        $config->{thumbnail}->{dir}->{$size},
            substr( $digest, 0, 1 ),
                substr( $digest, 1, 1 ),
                    $digest,
                        $config->{thumbnail}->{extension};
}

=head2 url2thumbpath( $url, $size )

Return md5_hex file name from url. Default size is medium.

=cut

sub url2thumbpath {
    my ( $url, $size ) = @_;

    return unless $url;

    my $config = saycheese_config();
    $size ||= $config->{thumbnail}->{default_size};
    my $thumbpath = digest2thumbpath( md5_hex( $url ), $size );
    my $dir = dirname( $thumbpath );
    mkpath( $dir ) unless -d $dir;

    return $thumbpath;
}

=head2 unescape_uri( $escaped_uri )

Unescape URI especialy %7E and %23.

=cut

sub unescape_uri {
    my $uri = shift;

    return unless $uri;

    $uri =~ s{%7E}{~}i;
    $uri =~ s{%23}{#}i;

    return $uri;
}

=head1 AUTHOR

travail, C<travail@travail.jp>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

package SayCheese::View::File;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
#    CATALYST_VAR => 'Catalyst',
    INCLUDE_PATH => [
        SayCheese->path_to( 'root', 'src' ),
        SayCheese->path_to( 'root', 'lib' ),
        SayCheese->path_to( 'root', 'static' ),
    ],
#    PRE_PROCESS  => 'config/main',
#    WRAPPER      => 'site/wrapper',
#    ERROR        => 'error.tt2',
#    TIMER        => 0
);

=head1 NAME

SayCheese::View::File - TT View for SayCheese

=head1 DESCRIPTION

TT View for SayCheese. 

=head1 AUTHOR

=head1 SEE ALSO

L<SayCheese>

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

package SayCheese::FileHandle;

use strict;
use warnings;
use base qw/ FileHandle /;

=head1 NAME

SayCheese::FileHandle - The SayCheese FileHandle

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=head2 slurp

Returns a scalar containing the contents of the temporary file.

=cut

sub slurp {
    my $self = shift;

    my $buff;
    $buff .= $_ while <$self>;

    return $buff;
}

=head1 AUTHOR

TRAVAIL

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

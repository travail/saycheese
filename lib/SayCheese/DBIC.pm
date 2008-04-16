package SayCheese::DBIC;

use base 'DBIx::Class';
use DateTime::Format::MySQL;
use URI;

=head1 NAME

SayCheese::DBIC - The SayCheese DBIx::Class

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=head2 datetime_column

Inflate and deflate datetime column.

=cut

sub datetime_column {
    my ( $class, @column ) = @_;

    $class->inflate_column( $_, {
        inflate => sub { DateTime::Format::MySQL->parse_datetime( shift ) },
        deflate => sub { DateTime::Format::MySQL->format_datetime( shift ) },
    } ) foreach @column;
}

=head2 uri_column

Infalte nad deflate uri column.

=cut

sub uri_column {
    my ( $class, @column ) = @_;

    $class->inflate_column( $_, {
        inflate => sub { URI->new( shift ) },
        deflate => sub { shift->as_string },
    } ) foreach @column;
}

=head1 AUTHOR

travail, C<travail@cabane.no-ip.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

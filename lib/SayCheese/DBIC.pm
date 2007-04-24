package SayCheese::DBIC;

use base 'DBIx::Class';
use Switch;
use DateTime::Format::MySQL;

sub register_column {
    my ( $class, $column ) = @_;

    $class->next::method( $column );
}

sub datetime_column {
    my ( $class, @column ) = @_;

    $class->inflate_column( $_, {
        inflate => sub { DateTime::Format::MySQL->parse_datetime( shift ) },
        deflate => sub { DateTime::Format::MySQL->format_datetime( shift ) },
    } ) foreach @column;
}

1;

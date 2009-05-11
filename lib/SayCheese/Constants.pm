package SayCheese::Constants;

use strict;
use warnings;
use base qw( Exporter );
use SayCheese::Config;

our @EXPORT = qw(
    CONFIG SUCCESS FAILURE
    ROWS CACHE_FOR
    ORIGINAL_WIDTH ORIGINAL_HEIGHT
    LARGE_WIDTH LARGE_HEIGHT
    MEDIUM_WIDTH MEDIUM_HEIGHT
    SMALL_WIDTH SMALL_HEIGHT
);

=head1 NAME

SayCheese::Constants - The SayCheese Constants

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 CONSTANTS

=head2 CONFIG

SayCheese config as C<HASHREF>.

=cut

use constant CONFIG => SayCheese::Config->instance->config;

use constant SUCCESS => 1;
use constant FAILURE => 0;

use constant ROWS => 20;
use constant CACHE_FOR => 60 * 60;

use constant ORIGINAL_WIDTH  => CONFIG->{thumbnail}->{size}->{original}->{width};
use constant ORIGINAL_HEIGHT => CONFIG->{thumbnail}->{size}->{original}->{height};
use constant LARGE_WIDTH     => CONFIG->{thumbnail}->{size}->{large}->{width};
use constant LARGE_HEIGHT    => CONFIG->{thumbnail}->{size}->{large}->{height};
use constant MEDIUM_WIDTH    => CONFIG->{thumbnail}->{size}->{medium}->{width};
use constant MEDIUM_HEIGHT   => CONFIG->{thumbnail}->{size}->{medium}->{height};
use constant SMALL_WIDTH     => CONFIG->{thumbnail}->{size}->{small}->{width};
use constant SMALL_HEIGHT    => CONFIG->{thumbnail}->{size}->{small}->{height};


=head1 AUTHOR

TRAVAIL

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

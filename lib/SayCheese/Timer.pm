package SayCheese::Timer;

use Moose;
use Time::HiRes ();
use constant MARK_START => 'start';
use constant MARK_STOP  => 'stop';

has marks => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

sub start {
    my $self = shift;

    $self->_clear;
    $self->set_mark(MARK_START);
}

sub stop { shift->set_mark(MARK_STOP) }

sub get_mark {
    my ($self, $mark) = @_;

    $self->marks->{$mark};
}

sub set_mark {
    my ($self, $mark) = @_;

    $self->marks->{$mark} = Time::HiRes::gettimeofday;
}

sub get_total_time {
    my $self = shift;

    $self->stop if !$self->get_mark(MARK_STOP);
    return $self->get_diff_time(MARK_START, MARK_STOP);
}

sub get_diff_time {
    my ($self, $start, $stop) = @_;

    my $t0 = $self->get_mark($start);
    my $t1 = $self->get_mark($stop);

    return Time::HiRes::tv_interval([$t0], [$t1]);
}

sub _clear {
    my $self = shift;

    $self->marks->{$_} = '' foreach keys %{ $self->marks };
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

SayCheese::Timer - The SayCheese Timer Class

=head1 SYNOPSIS

See L<SayCheese>

=head1 DESCRIPTION

=head1 METHODS

=cut

=head2

=cut

=head1 AUTHOR

TRAVAIL

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

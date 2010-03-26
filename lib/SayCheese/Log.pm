package SayCheese::Log;

use Moose;
with 'MooseX::Emulate::Class::Accessor::Fast';

use Data::Dump;
use Class::MOP ();

our %LEVELS      = (); # Levels stored as bit field, ergo debug = 1, warn = 2 etc
our %LEVEL_MATCH = (); # Stored as additive, thues debug = 31, warn = 32 etc

has level => (is => 'rw');
has _body => (is => 'rw');
has abort => (is => 'rw');

{
    my @levels = qw(debug info warn error fatal);

    my $meta = Class::MOP::get_metaclass_by_name(__PACKAGE__);
    my $summed_level = 0;
    for ( my $i = $#levels; $i >= 0; $i-- ) {
        my $name  = $levels[$i];
        my $level = 1 << $i;
        $summed_level |= $level;

        $LEVELS{$name} = $level;
        $LEVEL_MATCH{$name} = $summed_level;

        $meta->add_method($name, sub {
            my $self = shift;

            if ($self->level & $level) {
                $self->_log($name, @_);
            }
        });
    }
}

around new => sub {
    my $orig  = shift;
    my $class = shift;
    my $self  = $class->$orig;

    $self->levels(scalar(@_) ? @_ : keys %LEVELS);

    return $self;
};

sub levels {
    my ( $self, @levels ) = @_;

    $self->level(0);
    $self->enable(@levels);
}

sub enable {
    my ( $self, @levels ) = @_;

    my $level = $self->level;
    for ( map { $LEVEL_MATCH{$_} } @levels ) {
        $level |= $_;
    }
    $self->level($level);
}

sub disable {
    my ( $self, @levels ) = @_;

    my $level = $self->level;
    for ( map { $LEVELS{$_} } @levels ) {
        $level &= ~$_;
    }
    $self->level($level);
}

sub _dump {
    my $self = shift;
    $self->info( Data::Dump::dump(@_) );
}

sub _log {
    my $self  = shift;
    my $level = shift;

    my $message = join( "\n", @_ );
    $message .= "\n" unless $message =~ /\n$/;
    my $body = $self->_body;
    $body .= sprintf "[%s] %s", $level, $message;
    $self->_body($body);
}

sub _flush {
    my $self = shift;

    if ($self->abort || !$self->_body) {
        $self->abort(undef);
    }
    else {
        $self->_send_to_log($self->_body);
    }

    $self->_body(undef);
}

sub _send_to_log {
    my $self = shift;
    print STDERR @_;
}

my $meta = __PACKAGE__->meta;
$meta->add_method( 'body', $meta->get_method('_body') );
my %package_hash;
$meta->add_before_method_modifier('body', sub {
    my $class = blessed(shift);
    $package_hash{$class}++ || do {
        warn("Class $class is calling the deprecated method Catalyst::Log->body method,\n"
             . "this will be removed in Catalyst 5.81");
        };
    }
);

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__

=head1 NAME

SayCheese::Log - The SayCheese Log Class

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

__PACKAGE__->meta->make_immutable;

1;

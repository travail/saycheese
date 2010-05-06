package SayCheese::Queue::Q4M::Worker;

use Moose;
use Carp::Clan ();
use Parallel::Prefork;
use SayCheese::Config;
use SayCheese::Timer;
use SayCheese::Log;
use namespace::autoclean;

extends 'SayCheese::Queue::Q4M';

has 'max_workers' => (
    is       => 'rw',
    isa      => 'Int',
    default  => 1,
    required => 1,
);

has 'trap_signals' => (
    traits   => ['Hash'],
    is       => 'rw',
    isa      => 'HashRef[Str]',
    default  => sub { { TERM => 'TERM', HUP => 'TERM' } },
    required => 0,
    handles  => {
        set_signal    => 'set',
        get_signal    => 'get',
        delete_signal => 'delete',
    },
);

has 'config' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { SayCheese::Config->instance->config },
);

has 'connect_info' => (
    is       => 'rw',
    required => 1,
    lazy     => 1,
    builder  => '_build_connect_info'
);

has 'tables' => (
    is       => 'rw',
    required => 1,
    lazy     => 1,
    builder  => '_build_tables'
);

has 'columns' => (
    is       => 'rw',
    required => 1,
    lazy     => 1,
    builder  => '_build_columns'
);

has 'log' => (
    is      => 'rw',
    isa     => 'SayCheese::Log',
    default => sub { SayCheese::Log->new }
);

has 'timer' => (
    is      => 'rw',
    isa     => 'SayCheese::Timer',
    default => sub { SayCheese::Timer->new }
);

has 'debug' => (
    traits   => ['Bool'],
    is       => 'rw',
    isa      => 'Bool',
    default  => 0,
    required => 0,
);

has 'verbose' => (
    traits   => ['Bool'],
    is       => 'rw',
    isa      => 'Bool',
    default  => 0,
    required => 0,
);

sub _build_connect_info {
    $_[0]->config->{ $_[0]->meta->name }->{connect_info};
}

sub _build_tables {
    $_[0]->config->{ $_[0]->meta->name }->{tables};
}

sub _build_columns {
    $_[0]->config->{ $_[0]->meta->name }->{columns};
}

around 'work' => sub {
    my $orig = shift;
    my $self = shift;

    $self->log->info('=== STARTUP ===');
    $self->log->info( 'MAX_WORKERS: ' . $self->max_workers );
    $self->log->info( 'TIMEOUT: ' . $self->timeout );
    $self->log->info( 'TABLES: ' . join ', ',  @{ $self->tables } );
    $self->log->info( 'COLUMNS: ' . join ', ', @{ $self->columns } );
    $self->log->_flush;

    $self->$orig(@_);

    $self->log->finfo('=== SHUTDOWN ===');
};

__PACKAGE__->meta->make_immutable;

sub work {
    my $self = shift;

    my $pp = Parallel::Prefork->new(
        {
            max_workers  => $self->max_workers,
            fork_delay   => 1,
            trap_signals => $self->trap_signals,
        }
    );
    while ( $pp->signal_received ne 'TERM' ) {
        if ( $pp->signal_received ) {
            $self->log->finfo( 'Caught signal ' . $pp->signal_received );
        }
        $pp->start and next;
        $self->log->info("$$ start to work");
        $self->_work;
        $self->log->finfo("$$ finish to work\n\n");
        $pp->finish;
    }
    $pp->wait_all_children;
}

1;

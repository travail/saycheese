package SayCheese::Queue::Worker;

use Moose;
use Carp::Clan ();
use Parallel::Prefork;
use Queue::Q4M;
use SayCheese::Config;
use SayCheese::Log;
use SayCheese::Timer;
use Data::Dumper;

has 'config' => (
    is       => 'rw',
    isa      => 'HashRef',
    default  => sub { SayCheese::Config->instance->config },
    required => 1,
);

has 'connect_info' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 1,
    lazy     => 1,
    builder  => '_build_connect_info',
);

has 'tables' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 1,
    lazy     => 1,
    builder  => '_build_tables',
);

has 'columns' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 1,
    lazy     => 1,
    builder  => '_build_columns',
);

has 'queue' => (
    is       => 'ro',
    isa      => 'Queue::Q4M',
    required => 1,
    lazy     => 1,
    builder  => '_build_queue',
);

has 'log' => (
    is       => 'ro',
    isa      => 'SayCheese::Log',
    required => 1,
    lazy     => 1,
    builder  => '_build_log',
);

has 'timer' => (
    is       => 'ro',
    isa      => 'SayCheese::Timer',
    required => 1,
    lazy     => 1,
    builder  => '_build_timer',
);

has 'max_workers' => (
    is      => 'rw',
    isa     => 'Int',
);

has 'timeout' => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    builder => '_build_timeout',
);

has 'debug' => (
    is  => 'rw',
    isa => 'Int'
);

sub _build_connect_info { $_[0]->config->{ $_[0]->meta->name }->{connect_info} }
sub _build_tables  { $_[0]->config->{ $_[0]->meta->name }->{tables} }
sub _build_columns { $_[0]->config->{ $_[0]->meta->name }->{columns} }
sub _build_queue { Queue::Q4M->connect( connect_info => $_[0]->connect_info ) }
sub _build_log     { SayCheese::Log->new }
sub _build_timer   { SayCheese::Timer->new }
sub _build_timeout { $_[0]->config->{ $_[0]->meta->name }->{timeout} }

around 'enqueue' => sub {
    my ( $orig, $self, $table, $fields ) = @_;

    $fields ||= {};
    $table  ||= $self->tables->[0];
    if ($self->debug) {
        $self->log->debug("Queue in $table");
        $self->log->_dump($fields);
    }
    $self->$orig($table, $fields);
};

around 'dequeue' => sub {
    my ( $orig, $self, $table, $columns ) = @_;

    $table   ||= $self->tables->[0];
    $columns ||= $self->columns;
    $self->$orig( $table, $columns );
};

around 'dequeue_array' => sub {
    my ( $orig, $self, $table, $columns ) = @_;

    $table   ||= $self->tables->[0];
    $columns ||= $self->columns;
    $self->$orig( $table, $columns );
};

around 'dequeue_arrayref' => sub {
    my ( $orig, $self, $table, $columns ) = @_;

    $table   ||= $self->tables->[0];
    $columns ||= $self->columns;
    $self->$orig( $table, $columns );
};

around 'dequeue_hashref' => sub {
    my ($orig, $self, $table, $columns) = @_;

    $table   ||= $self->tables->[0];
    $columns ||= $self->columns;
    $self->$orig($table, $columns);
};

__PACKAGE__->meta->make_immutable;

sub enqueue { $_[0]->queue->insert( $_[1], $_[2] ) }

sub next {
    my ( $self, $conds, $timeout ) = @_;

    $conds   ||= [];
    $timeout ||= $self->timeout;

    my @tables = ();
    for (my $i = 0; $i < @{$conds}; $i++) {
        next if !$conds->[$i];
        my $table = sprintf '%s:%s', $self->tables->[$i], $conds->[$i];
        push @tables, $table;
    }
    @tables = @tables ? @tables : @{$self->tables};

    $self->queue->next( @tables, $timeout );
}

sub dequeue { $_[0]->queue->fetch( $_[1], $_[2] ) }

sub dequeue_array { $_[0]->queue->fetch_array( $_[1], $_[2] ) }

sub dequeue_arrayref { $_[0]->queue->fetch_arrayref( $_[1], $_[2] ) }

sub dequeue_hashref { $_[0]->queue->fetch_hashref( $_[1], $_[2] ) }

sub end {
    my $self = shift;

    $self->queue->dbh->do('SELECT queue_end()')
      || Carp::Clan::croak( $self->queue->dbh->errstr );
}

sub abort {
    my $self = shift;

    $self->queue->dbh->do('SELECT queue_abort()')
      || Carp::Clan::croak( $self->queue->dbh->errstr );
}

sub work {
    my $self = shift;

    my $pp = Parallel::Prefork->new({
        max_workers  => $self->max_workers,
        fork_delay   => 1,
        trap_signals => {
            TERM => 'TERM',
            HUP  => 'TERM',
        },
    });
    while ($pp->signal_received ne 'TERM') {
        $pp->start and next;
        $self->log->info("(PID: $$) Start to work");
        $self->_work;
        $self->log->info("(PID: $$) Finish to work");
        $self->log->_flush;
        $pp->finish;
    }
    $pp->wait_all_children;
}

=head1 NAME

SayCheese::Queue::Worker - SayCheese Queue Worker

=head1 DESCRIPTION

SayCheese Queue Worker

=head1 METHODS

=cut

=head2 enqueue

=cut

=head2 next

=cut

=head2 dequeue

=cut

=head2 dequeue_array

=cut

=head2 dequeue_arrayref

=cut

=head2 dequeue_hashref

=cut

=head2 end

=cut

=head2 abort

=cut

=head2 work

=cut

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

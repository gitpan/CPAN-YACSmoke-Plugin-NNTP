=head1 NAME

CPAN::YACSmoke::Plugin::NNTP - NNTP list for Yet Another CPAN Smoke Tester

=head1 SYNOPSIS

  use CPAN::YACSmoke;
  my $config = {
	  list_from => 'NNTP', 
      nntp_id => 180500 # NNTP id to start from (*)
  };
  my $foo = CPAN::YACSmoke->new(config => $config);
  my @list = $foo->download_list($testrun);

  # (*) defaults to the last id it saw.

=head1 DESCRIPTION

This module provides the backend ability to access the list of current
modules direct from the newsgroup, as posted by PAUSE.

This module should be use together with CPAN::YACSmoke.

=cut

package CPAN::YACSmoke::Plugin::NNTP;
use strict;

our $VERSION = '0.01';

# -------------------------------------
# Library Modules

use lib qw(./lib);

use Net::NNTP;
use Storable;
use Carp;

# -------------------------------------
# Constants

use constant	STORAGE	=> '/cpansmoke.store';
use constant    NNTP    => 'nntp.perl.org';
use constant    GROUP   => 'perl.cpan.testers';
use constant    LIMIT   => 100;

# -------------------------------------
# Variables

my $last_key = 0;

# -------------------------------------
# The Subs

=head1 CONSTRUCTOR

=over 4

=item new()

Creates the plugin object.

=back

=cut
    
sub new {
    my $class = shift || __PACKAGE__;
    my $hash  = shift;

    my $self = {};
    foreach my $field (qw( smoke nntp_id )) {
        $self->{$field} = $hash->{$field}   if(exists $hash->{$field});
    }

    bless $self, $class;
}

=head1 METHODS

=over 4

=item download_list($keep)

Download the list of distributions uploaded since the last stored 'nntp_id'.
If $keep is set, the old value is retained, rather than resetting with the
latest id.

=cut
    
sub download_list {
    my $self = shift;
	my $testrun = shift || 0;
    my @modules;

    my $cutoff = $self->{nntp_id} || $self->_get_storage();

	my $nntp = Net::NNTP->new(NNTP) || croak 'Cannot connect to '.NNTP;
	my (undef, undef, $last_key) = $nntp->group(GROUP);

	foreach my $id ($cutoff .. $last_key) {
		my $headers = join "", @{$nntp->head($id) || []};

        next    unless($headers =~ /CPAN Upload:\s+(.*?)\b/s);
		push @modules, $1;
	}

    $self->_put_storage($last_key)	if($testrun);

    return @modules;
}

sub _get_storage {
    my $self  = shift;
    my $store = $self->{smoke}->basedir() . STORAGE;
    my $smoke = retrieve($store)    if(-r $store);

    return 1    unless($smoke);
    return $smoke->{nntp_id};
}

sub _put_storage {
    my $self  = shift;
    my $nntp  = shift;
    my $store = $self->{smoke}->basedir() . STORAGE;
    my $smoke = {};

    $smoke = retrieve($store)   if(-r $store);
    $smoke->{nntp_id} = $nntp;
    store $smoke, $store;
}

1;
__END__

=pod

=back

=head1 CAVEATS

This is a proto-type release. Use with caution and supervision.

The current version has a very primitive interface and limited
functionality.  Future versions may have a lot of options.

There is always a risk associated with automatically downloading and
testing code from CPAN, which could turn out to be malicious or
severely buggy.  Do not run this on a critical machine.

This module uses the backend of CPANPLUS to do most of the work, so is
subject to any bugs of CPANPLUS.

=head2 Suggestions and Bug Reporting

Please submit suggestions and report bugs to the CPAN Bug Tracker at
L<http://rt.cpan.org>.

=head1 SEE ALSO

The CPAN Testers Website at L<http://testers.cpan.org> has information
about the CPAN Testing Service.

For additional information, see the documentation for these modules:

  CPANPLUS
  Test::Reporter
  CPAN::YACSmoke

=head1 AUTHOR

Barbie, C< <<barbie@cpan.org>> >
for Miss Barbell Productions, L<http://www.missbarbell.co.uk>

Birmingham Perl Mongers, L<http://birmingham.pm.org/>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2005 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This module is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

=cut

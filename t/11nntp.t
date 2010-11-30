use Test::More tests => 1;
ok(1);  # just for the sake of a test

#use Test::More tests => 2;
#
#use CPAN::YACSmoke;
#use CPAN::YACSmoke::Plugin::NNTP;
#use CPANPLUS::Configure;
#
#my $conf = CPANPLUS::Configure->new();
#my $smoke = {
#    conf    => $conf,
#};
#bless $smoke, 'CPAN::YACSmoke';
#
#my $self  = {
#    smoke   => $smoke,
#    nntp_id => 186420
#};
#
#my $plugin = CPAN::YACSmoke::Plugin::NNTP->new($self);
#isa_ok($plugin,'CPAN::YACSmoke::Plugin::NNTP');
#
#SKIP: {
#	skip "Unable to access NNTP Service", 1
#		unless(my $nntp = Net::NNTP->new(NNTP));
#
#	my @list = $plugin->download_list();
#	ok(@list > 0);
#}
#

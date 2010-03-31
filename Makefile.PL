
# $Id: Makefile.PL,v 1.4 2010-03-31 03:37:52 Martin Exp $

use inc::Module::Install;

all_from('lib/WWW/Search/Ebay/Europe.pm');

requires(perl => 5.005);
test_requires('Bit::Vector');
requires('Date::Manip');
test_requires('Date::Manip');
requires('HTML::TreeBuilder');
test_requires('IO::Capture::Stderr');
requires('LWP::Simple');
# Test::More is needed for `make test`:
test_requires('Test::More');
test_recommends('Test::Pod');
test_recommends('Test::Pod::Coverage');
# We need the version that has methods named with leading underscore:
requires('WWW::Search' => 2.557);
requires('WWW::Search::Ebay');
# We need the version that has the bidder and seller methods:
requires('WWW::SearchResult' => 2.067);
# We need the version that exports its tm_ functions:
test_requires('WWW::Search::Test' => 2.265);
# We need the version with test_most_results():
test_requires('WWW::Search::Test' => 2.284);

WriteAll;

sub MY::postamble
  {
  my $ret = <<'PART0';
coverage :
	$(RM_RF) cover_db/*
	$(MAKE) HARNESS_PERL_SWITCHES=-MDevel::Cover test
	cover
PART0
  return $ret;
  } # MY::postamble

__END__


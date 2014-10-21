
# $Id: it.t,v 1.2 2008/08/03 02:29:28 Martin Exp $

use Bit::Vector;
use Data::Dumper;
use ExtUtils::testlib;
use Test::More no_plan;

BEGIN { use_ok('Date::Manip') };
&Date_Init('TZ=-0500');
BEGIN { use_ok('WWW::Search') };
BEGIN { use_ok('WWW::Search::Test') };
BEGIN { use_ok('WWW::Search::Ebay::IT') };

use strict;

my $iDebug;
my $iDump = 0;

&tm_new_engine('Ebay::IT');
# goto SKIP_ZERO;
# goto CONTENTS;

diag("Sending 0-page query to ebay.it...");
$iDebug = 0;
# This test returns no results (but we should not get an HTTP error):
&tm_run_test('normal', $WWW::Search::Test::bogus_query, 0, 0, $iDebug);
SKIP_ZERO:
;
MULTI_RESULT:
diag("Sending multi-page query to ebay.it...");
$iDebug = 0;
$iDump = 0;
# This query returns many of pages of results:
&tm_run_test('normal', 'scatola', 101, undef, $iDebug);
# goto ALL_DONE;
DEBUG_NOW:
;
CONTENTS:
diag("Sending 1-page query to ebay.it to check contents...");
$iDebug = 0;
$iDump = 0;
&tm_run_test('normal', 'trinidad', 1, 99, $iDebug, $iDump);
# Now get the results and inspect them:
my @ao = $WWW::Search::Test::oSearch->results();
cmp_ok(0, '<', scalar(@ao), 'got some results');
# We perform this many tests on each result object:
my $iAnyFailed = my $iResult = 0;
my ($iVall, %hash);
my $sBidPattern = 'bid\s'. $WWW::Search::Test::oSearch->_currency_pattern;
my $qrBid = qr{\b$sBidPattern};
# print STDERR " DDD qrBid ==$qrBid==\n";
foreach my $oResult (@ao)
  {
  $iResult++;
  my $oV = new Bit::Vector(5);
  $oV->Fill;
  $iVall = $oV->to_Dec;
  # Create a vector of which tests passed:
  $oV->Bit_Off(0) unless like($oResult->description,
                              $qrBid,
                              'result bid amount is ok');
  $oV->Bit_Off(1) unless like($oResult->url,
                              qr{\Ahttp://cgi\d*\.ebay\.it}, # } # Emacs indent
                              'result URL is really from ebay.it');
  $oV->Bit_Off(2) unless cmp_ok($oResult->title, 'ne', '',
                                'result Title is not empty');
  $oV->Bit_Off(3) unless cmp_ok(&ParseDate($oResult->change_date) || '',
                                'ne', '',
                                'change_date is really a date');
  $oV->Bit_Off(4) unless like($oResult->description,
                              qr{([0-9]+|no)\s+bids?}, # } # Emacs indent
                              'result bidcount is ok');
  $oV->Bit_Off(5) unless like($oResult->bid_count, qr{\A\d+\Z},
                              'bid_count is a number');
  my $iV = $oV->to_Dec;
  if ($iV < $iVall)
    {
    $hash{$iV} = $oResult;
    $iAnyFailed++;
    } # if
  } # foreach
if ($iAnyFailed)
  {
  diag(" Here are results that exemplify the failures:");
  while (my ($sKey, $sVal) = each %hash)
    {
    diag(Dumper($sVal));
    } # while
  } # if

ALL_DONE:
pass('all done');

__END__


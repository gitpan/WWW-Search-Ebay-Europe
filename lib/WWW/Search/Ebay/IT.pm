
# $Id: IT.pm,v 1.3 2008/08/03 02:47:24 Martin Exp $

=head1 NAME

WWW::Search::Ebay::IT - backend for searching auctions at eBay Italy

=head1 DESCRIPTION

Acts just like WWW::Search::Ebay.

=head1 AUTHOR

C<WWW::Search::Ebay::IT> was written by and is maintained by
Martin Thurn C<mthurn@cpan.org>, L<http://tinyurl.com/nn67z>.

=cut

package WWW::Search::Ebay::IT;

use strict;
use warnings;

use Carp;
use base 'WWW::Search::Ebay';
our
$VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%03d" x $#r, @r };

sub _native_setup_search
  {
  my ($self, $native_query, $rhOptsArg) = @_;
  $rhOptsArg ||= {};
  unless (ref($rhOptsArg) eq 'HASH')
    {
    carp " --- second argument to _native_setup_search should be hashref, not arrayref";
    return undef;
    } # unless
  $rhOptsArg->{search_host} = 'http://search.ebay.it';
  return $self->SUPER::_native_setup_search($native_query, $rhOptsArg);
  } # _native_setup_search

# This is what we look_down for to find the HTML element that contains
# the result count:
sub _result_count_element_specs
  {
  return (
          _tag => 'div',
          class => 'fpc'
         );
  } # _result_count_element_specs


sub _result_count_pattern
  {
  return qr'(\d+) (oggetti|inserzioni) trovat[ei] ';
  } # _result_count_pattern

sub _next_text
  {
  # The text of the "Next" button, localized:
  return 'Successivo';
  } # _next_text

sub _currency_pattern
  {
  my $self = shift;
  # A pattern to match all possible currencies found in eBay listings
  # (if one character looks weird, it's really a British Pound symbol
  # but Emacs shows it wrong):
  my $W = $self->whitespace_pattern;
  return qr{(?:US\s?\$|�|EUR)$W*[\d.,]+}; # } } # Emacs indentation bugfix
  } # _currency_pattern

sub _preprocess_results_page_OFF
  {
  my $self = shift;
  my $sPage = shift;
  # print STDERR Dumper($self->{response});
  # For debugging:
  print STDERR $sPage;
  exit 88;
  } # _preprocess_results_page

sub _columns
  {
  my $self = shift;
  # This is for IT:
  return qw( paypal price bids shipping enddate );
  } # _columns

sub _process_date_abbrevs
  {
  my $self = shift;
  my $s = shift;
  # Convert Italian abbreviations for units of time to something
  # Date::Manip can parse (namely, English words):
  $s =~ s!(\d)g!$1 days!;
  $s =~ s!(\d)h!$1 hours!;
  $s =~ s!(\d)m!$1 minutes!;
  return $s;
  } # _process_date_abbrevs


1;

__END__


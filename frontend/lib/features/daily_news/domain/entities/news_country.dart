/// Countries the news provider can filter top headlines by.
///
/// [code] is the two-letter ISO value the provider expects; [label] is the
/// name shown to the user.
enum NewsCountry {
  argentina('ar', 'Argentina'),
  australia('au', 'Australia'),
  austria('at', 'Austria'),
  belgium('be', 'Belgium'),
  brazil('br', 'Brazil'),
  canada('ca', 'Canada'),
  colombia('co', 'Colombia'),
  france('fr', 'France'),
  germany('de', 'Germany'),
  india('in', 'India'),
  ireland('ie', 'Ireland'),
  italy('it', 'Italy'),
  japan('jp', 'Japan'),
  mexico('mx', 'Mexico'),
  netherlands('nl', 'Netherlands'),
  newZealand('nz', 'New Zealand'),
  norway('no', 'Norway'),
  portugal('pt', 'Portugal'),
  southAfrica('za', 'South Africa'),
  spain('es', 'Spain'),
  sweden('se', 'Sweden'),
  switzerland('ch', 'Switzerland'),
  unitedKingdom('gb', 'United Kingdom'),
  unitedStates('us', 'United States'),
  venezuela('ve', 'Venezuela');

  /// Value expected by the provider's `country` query parameter.
  final String code;

  /// Human-readable name.
  final String label;

  const NewsCountry(this.code, this.label);

  static const NewsCountry fallback = unitedStates;

  /// Resolves a stored code; unknown values fall back to [fallback].
  static NewsCountry fromCode(String? code) {
    final needle = code?.trim().toLowerCase();
    return NewsCountry.values.firstWhere(
      (country) => country.code == needle,
      orElse: () => fallback,
    );
  }
}

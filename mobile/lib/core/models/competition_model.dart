class CompetitionModel {
  final String id;
  final String name;
  final String? country;
  final String? logoUrl;
  final String? season;
  final String type;

  const CompetitionModel({
    required this.id,
    required this.name,
    this.country,
    this.logoUrl,
    this.season,
    this.type = 'league',
  });

  factory CompetitionModel.fromJson(Map<String, dynamic> json) => CompetitionModel(
        id: json['id'] as String,
        name: json['name'] as String,
        country: json['country'] as String?,
        logoUrl: json['logoUrl'] as String?,
        season: json['season'] as String?,
        type: json['type'] as String? ?? 'league',
      );
}

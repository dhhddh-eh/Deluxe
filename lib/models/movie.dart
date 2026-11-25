class Movie {
  final String id;
  final String title;
  final int year;
  final String description;
  final String watchUrl;
  final String videoUrl;
  final String sourceLabel;
  final bool publicDomain;

  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.description,
    required this.watchUrl,
    required this.videoUrl,
    required this.sourceLabel,
    this.publicDomain = true,
  });
}

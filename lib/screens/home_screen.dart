import 'package:flutter/material.dart';
import '../data/sample_movies.dart';
import '../models/movie.dart';
import '../services/pro_service.dart';
import 'movie_detail_screen.dart';
import 'pro_screen.dart';

class HomeScreen extends StatefulWidget {
  final ProService proService;

  const HomeScreen({super.key, required this.proService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  bool _favoritesOnly = false;

  List<Movie> get _filteredMovies {
    final pro = widget.proService.isPro.value;
    final favorites = widget.proService.favorites;

    return sampleMovies.where((movie) {
      final matchesQuery = _query.isEmpty ||
          movie.title.toLowerCase().contains(_query.toLowerCase()) ||
          movie.description.toLowerCase().contains(_query.toLowerCase());

      final matchesFavorites = !_favoritesOnly || favorites.contains(movie.id);

      return matchesQuery && matchesFavorites;
    }).toList();
  }

  Future<void> _openPro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProScreen(proService: widget.proService),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.proService.isPro,
      builder: (context, _) {
        final isPro = widget.proService.isPro.value;

        return Scaffold(
          appBar: AppBar(
            title: const Text('LazyMedia Deluxe'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text(isPro ? 'PRO' : 'FREE'),
                  backgroundColor:
                      isPro ? Colors.green.shade700 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              if (!isPro)
                MaterialBanner(
                  content: const Text(
                    'Pro открывает поиск и избранное. Демо-версия для разработки.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: _openPro,
                      child: const Text('Открыть Pro'),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  readOnly: !isPro,
                  onTap: !isPro ? _openPro : null,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: isPro
                        ? 'Поиск фильмов...'
                        : 'Поиск доступен в Pro',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Только избранное'),
                      selected: _favoritesOnly,
                      onSelected: (value) {
                        if (!isPro) {
                          _openPro();
                          return;
                        }
                        setState(() => _favoritesOnly = value);
                      },
                    ),
                    const Spacer(),
                    Text('${_filteredMovies.length} фильмов'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _filteredMovies[index];
                    final isFavorite =
                        widget.proService.isFavorite(movie.id);

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(movie.title.substring(0, 1)),
                      ),
                      title: Text('${movie.title} (${movie.year})'),
                      subtitle: Text(
                        movie.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isFavorite
                          ? const Icon(Icons.favorite, color: Colors.red)
                          : const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(
                              movie: movie,
                              proService: widget.proService,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

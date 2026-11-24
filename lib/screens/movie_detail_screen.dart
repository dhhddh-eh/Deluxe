import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../services/pro_service.dart';
import 'pro_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final ProService proService;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.proService,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Future<void> _openSource() async {
    final uri = Uri.parse(widget.movie.watchUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку источника.')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (!widget.proService.isPro.value) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProScreen(proService: widget.proService),
        ),
      );
      setState(() {});
      return;
    }

    await widget.proService.toggleFavorite(widget.movie.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = widget.proService.isFavorite(widget.movie.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('${widget.movie.year} • ${widget.movie.sourceLabel}'),
                  const SizedBox(height: 16),
                  Text(widget.movie.description),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openSource,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Открыть легальный источник'),
          ),
          const SizedBox(height: 12),
          Text(
            widget.movie.publicDomain
                ? 'Материал отмечен как public domain / открытая лицензия. Проверяйте условия источника.'
                : 'Проверяйте лицензию источника перед использованием.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

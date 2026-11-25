import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController _controller;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.movie.videoUrl));
    _controller
        .initialize()
        .then((_) {
          if (mounted) setState(() => _initialized = true);
          _controller.play();
        })
        .catchError((e) {
          if (mounted) setState(() => _error = e.toString());
        });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isFav = widget.proService.isFavorite(widget.movie.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Не удалось загрузить видео.\n$_error',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : !_initialized
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_controller),
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                child: AnimatedOpacity(
                                  opacity: _controller.value.isPlaying ? 0 : 1,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    color: Colors.black38,
                                    child: const Icon(
                                      Icons.play_arrow,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          if (_initialized) ...[
            const SizedBox(height: 8),
            VideoProgressIndicator(_controller, allowScrubbing: true),
            Row(
              children: [
                IconButton(
                  icon: Icon(_controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
                Text(
                  '${_fmt(_controller.value.position)} / ${_fmt(_controller.value.duration)}',
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () => _controller.seekTo(
                    _controller.value.position - const Duration(seconds: 10),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () => _controller.seekTo(
                    _controller.value.position + const Duration(seconds: 10),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
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
          OutlinedButton.icon(
            onPressed: _openSource,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Открыть источник'),
          ),
        ],
      ),
    );
  }
}

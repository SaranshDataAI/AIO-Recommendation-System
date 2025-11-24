import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models.dart';
import '../../services/watchlist_service.dart';

class DetailPage extends StatefulWidget {
  final ContentItem item;

  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isInWatchlist = false;
  bool _loadingState = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlistState();
  }

  Future<void> _loadWatchlistState() async {
    final exists = await WatchlistService.isInWatchlist(widget.item.id);
    if (mounted) {
      setState(() {
        _isInWatchlist = exists;
        _loadingState = false;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    await WatchlistService.toggleWatchlist(widget.item);
    await _loadWatchlistState();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final runtimeText =
        item.runtime == null || item.runtime == 0 ? null : '${item.runtime!.round()} min';

    return Scaffold(
      backgroundColor: const Color(0xFF050A0F),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 900;

            final poster = ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: item.posterUrl.isEmpty
                    ? 'https://via.placeholder.com/600x900?text=No+Image'
                    : item.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF111827),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF111827),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined, size: 32),
                ),
              ),
            );

            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (item.type.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00ED82),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    if (runtimeText != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        runtimeText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.genres.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.genres,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Add to My List button (Option A)
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loadingState ? null : _toggleWatchlist,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isInWatchlist ? Colors.white10 : const Color(0xFF00ED82),
                        foregroundColor: _isInWatchlist ? Colors.white : Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(
                            color: _isInWatchlist
                                ? Colors.white.withOpacity(0.4)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      icon: _isInWatchlist
                          ? const Icon(Icons.check_rounded)
                          : const Icon(Icons.add_rounded),
                      label: Text(
                        _isInWatchlist ? 'Added to My List' : 'Add to My List',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.overview.isEmpty
                      ? 'No overview available for this title.'
                      : item.overview,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white.withOpacity(0.86),
                  ),
                ),
              ],
            );

            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF050A0F),
                        Color(0xFF020617),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth * 0.3,
                                child: AspectRatio(
                                  aspectRatio: 2 / 3,
                                  child: poster,
                                ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(child: details),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 2 / 3,
                                child: poster,
                              ),
                              const SizedBox(height: 20),
                              details,
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

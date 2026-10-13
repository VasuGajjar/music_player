import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../music_player.dart';

/// Search YouTube, stream a result through the regular player or download its audio
/// into the library. Backed by NewPipeExtractor via [YouTube].
class OnlineScreen extends StatefulWidget {
  final String initialQuery;

  const OnlineScreen({Key? key, this.initialQuery = ''}) : super(key: key);

  static Future<void> open(BuildContext context, [String query = '']) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => OnlineScreen(initialQuery: query.trim())));

  @override
  State<OnlineScreen> createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen> {
  late final controller = TextEditingController(text: widget.initialQuery);
  final focus = FocusNode();
  // ponytail: session-only; persist in a Hive box if people want them across launches.
  static final List<String> recent = [];

  String? query, error;
  bool loading = false;
  List<OnlineVideo> results = [];
  List<String> suggestions = [];
  Timer? suggestionDebounce;

  /// Video being resolved to stream urls (tap to play / download).
  String? resolving;

  /// Video url → the stream url it was played with, to highlight what's playing.
  final Map<String, String> streamed = {};
  late final StreamSubscription<String> errorSubscription;

  @override
  void initState() {
    super.initState();
    focus.addListener(() => setState(() {}));
    errorSubscription = YouTube.errors.stream.listen(showError);
    if (widget.initialQuery.isNotEmpty) WidgetsBinding.instance.addPostFrameCallback((_) => search(widget.initialQuery));
  }

  String get text => controller.text.trim();

  /// Typing a new query: show suggestions over the results.
  bool get editing => focus.hasFocus && text.isNotEmpty && text != query;

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> search(String value) async {
    final q = value.trim();
    if (q.isEmpty) return;
    focus.unfocus();
    controller.value = TextEditingValue(text: q, selection: TextSelection.collapsed(offset: q.length));
    setState(() {
      query = q;
      loading = true;
      error = null;
      recent
        ..remove(q)
        ..insert(0, q);
      if (recent.length > 8) recent.removeLast();
    });
    try {
      final items = await YouTube.search(q);
      if (mounted && query == q) setState(() => results = items);
    } on PlatformException catch (e) {
      if (mounted && query == q) setState(() => error = e.message ?? 'Search failed');
    } finally {
      if (mounted && query == q) setState(() => loading = false);
    }
  }

  void onChanged(String _) {
    setState(() {});
    suggestionDebounce?.cancel();
    final q = text;
    if (q.isEmpty) return setState(() => suggestions = []);
    suggestionDebounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        final items = await YouTube.suggestions(q);
        if (mounted && text == q) setState(() => suggestions = items);
      } on PlatformException {
        // Suggestions are a nicety; typing + submit still works.
      }
    });
  }

  void editQuery(String q) {
    controller.value = TextEditingValue(text: q, selection: TextSelection.collapsed(offset: q.length));
    focus.requestFocus();
    onChanged(q);
  }

  void clearQuery() {
    controller.clear();
    focus.requestFocus();
    setState(() {
      query = null;
      suggestions = [];
    });
  }

  Future<List<OnlineAudio>?> resolve(OnlineVideo video) async {
    if (resolving != null) return null;
    setState(() => resolving = video.url);
    try {
      final streams = await YouTube.audioStreams(video.url);
      if (streams.isEmpty) showError('No audio found for this video');
      return streams.isEmpty ? null : streams;
    } on PlatformException catch (e) {
      showError(e.message ?? 'Could not load this video');
      return null;
    } finally {
      if (mounted) setState(() => resolving = null);
    }
  }

  Future<void> play(OnlineVideo video) async {
    final streams = await resolve(video);
    if (streams == null || !mounted) return;
    final audio = streams.first;
    setState(() => streamed[video.url] = audio.url);
    context.read<PlayerBloc>()
      ..add(PlayerNewSong(songs: [YouTube.songFor(video, audio)], currentIndex: 0))
      ..add(PlayerPlayPause(true));
  }

  Future<void> pickQuality(OnlineVideo video) async {
    final streams = (await resolve(video))?.where((stream) => stream.downloadable).toList();
    if (streams == null || !mounted) return;
    if (streams.isEmpty) return showError('No downloadable audio for this video');

    final scheme = Theme.of(context).colorScheme;
    final audio = await showModalBottomSheet<OnlineAudio>(
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Constant.radiusMedium))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text('Download audio', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            ),
            for (final stream in streams)
              ListTile(
                title: Text(stream.label),
                trailing: Text(stream.sizeText(video.duration), style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                onTap: () => Navigator.pop(context, stream),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (audio != null) YouTube.download(video, audio);
  }

  void openDownloads() => showModalBottomSheet(
        context: context,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Constant.radiusMedium))),
        builder: (context) => ValueListenableBuilder(
          valueListenable: YouTube.downloads,
          builder: (context, map, _) {
            final scheme = Theme.of(context).colorScheme;
            final saved = map.values.where((progress) => progress == 1).length;
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Row(
                      children: [
                        const Expanded(child: Text('Downloads', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                        Text('$saved saved', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (map.isEmpty)
                    const EmptyState(icon: PhosphorIcons.downloadSimple, text: 'Nothing downloaded yet')
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 8),
                        children: [
                          for (final MapEntry(key: id, value: progress) in map.entries)
                            ListTile(
                              leading: _Thumbnail(video: YouTube.videoFor(id), width: 72, showDuration: false),
                              title: Text(YouTube.videoFor(id)?.title ?? id, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(progress < 1 ? 'Downloading · ${(progress * 100).round()}%' : 'Saved to library'),
                              trailing: progress < 1
                                  ? _DownloadButton(progress: progress, onDownload: () {}, onCancel: () => YouTube.cancel(id))
                                  : IconButton(
                                      tooltip: 'Clear from list',
                                      onPressed: () => YouTube.dismiss(id),
                                      icon: const Icon(PhosphorIcons.x),
                                    ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 0,
        title: DecoratedBox(
          decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(Constant.radiusLarge)),
          child: TextField(
            controller: controller,
            focusNode: focus,
            autofocus: widget.initialQuery.isEmpty,
            textInputAction: TextInputAction.search,
            onSubmitted: search,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search YouTube',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: Icon(PhosphorIcons.youtubeLogo, size: 20, color: scheme.onSurfaceVariant),
              prefixIconConstraints: const BoxConstraints(minWidth: 44),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      onPressed: clearQuery,
                      icon: const Icon(PhosphorIcons.x),
                    ),
              suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: YouTube.downloads,
            builder: (context, map, _) {
              final active = map.values.where((progress) => progress < 1).length;
              return IconButton(
                tooltip: 'Downloads',
                onPressed: openDownloads,
                icon: Badge(
                  isLabelVisible: active > 0,
                  label: Text('$active'),
                  backgroundColor: scheme.primary,
                  textColor: scheme.onPrimary,
                  child: const Icon(PhosphorIcons.downloadSimple),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: body(scheme)),
      bottomNavigationBar: const PlayerTile(),
    );
  }

  Widget body(ColorScheme scheme) {
    if (editing) return suggestionList();
    if (query == null || text.isEmpty) return discover(scheme);
    if (loading) {
      return ListView.builder(
        key: const ValueKey('loading'),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerTile(leading: Size(96, 54)),
      );
    }
    if (error != null) {
      return EmptyState(
        key: const ValueKey('error'),
        icon: PhosphorIcons.warning,
        text: error!,
        action: TextButton.icon(
          onPressed: () => search(query!),
          icon: const Icon(PhosphorIcons.arrowCounterClockwise, size: 18),
          label: const Text('Retry'),
        ),
      );
    }
    if (results.isEmpty) return const EmptyState(key: ValueKey('empty'), icon: PhosphorIcons.youtubeLogo, text: 'No results');
    return resultList();
  }

  Widget sectionHeader(ColorScheme scheme, String text, {Widget? action}) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
              ),
              if (action != null) action,
            ],
          ),
        ),
      );

  Widget queryTile(String q, IconData icon) => ListTile(
        leading: Icon(icon),
        title: Text(q, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () => search(q),
        trailing: IconButton(
          tooltip: 'Edit',
          onPressed: () => editQuery(q),
          icon: const Icon(PhosphorIcons.arrowUpLeft),
        ),
      );

  Widget suggestionList() => ListView(
        key: const ValueKey('suggestions'),
        padding: const EdgeInsets.only(top: 8, bottom: 160),
        children: [
          for (final q in recent.where((q) => q.toLowerCase().startsWith(text.toLowerCase())).take(3)) queryTile(q, PhosphorIcons.clockCounterClockwise),
          for (final q in suggestions.where((q) => !recent.contains(q))) queryTile(q, PhosphorIcons.magnifyingGlass),
        ],
      );

  Widget discover(ColorScheme scheme) => ListView(
        key: const ValueKey('discover'),
        padding: const EdgeInsets.only(bottom: 160),
        children: [
          if (recent.isNotEmpty) ...[
            sectionHeader(scheme, 'Recent', action: TextButton(onPressed: () => setState(recent.clear), child: const Text('Clear'))),
            for (final q in recent) queryTile(q, PhosphorIcons.clockCounterClockwise),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(PhosphorIcons.info, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap a result to stream it. Download the audio to keep it in your library for offline play.',
                    style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget resultList() {
    final current = context.select((PlayerBloc bloc) {
      final state = bloc.state;
      final index = state.currentIndex;
      return index != null && index < state.songs.length ? state.songs[index].filePath : null;
    });
    return ListView.builder(
      key: ValueKey(query),
      padding: const EdgeInsets.only(top: 8, bottom: 160),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final video = results[index];
        final playing = current != null && streamed[video.url] == current;
        return ValueListenableBuilder(
          valueListenable: YouTube.downloads,
          builder: (context, map, _) => ListTile(
            onTap: () => play(video),
            selected: playing,
            leading: _Thumbnail(video: video, streaming: playing, loading: resolving == video.url),
            title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(video.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: _DownloadButton(
              progress: map[video.url],
              onDownload: () => pickQuality(video),
              onCancel: () => YouTube.cancel(video.url),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    suggestionDebounce?.cancel();
    errorSubscription.cancel();
    focus.dispose();
    controller.dispose();
    super.dispose();
  }
}

/// Download → progress ring (tap to cancel) → saved check.
class _DownloadButton extends StatelessWidget {
  final double? progress;
  final VoidCallback onDownload, onCancel;

  const _DownloadButton({required this.progress, required this.onDownload, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = progress;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: switch (p) {
        null => IconButton(
            key: const ValueKey('idle'),
            tooltip: 'Download',
            onPressed: onDownload,
            icon: const Icon(PhosphorIcons.downloadSimple),
          ),
        < 1 => IconButton(
            key: const ValueKey('active'),
            tooltip: 'Cancel download',
            onPressed: onCancel,
            icon: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.square(
                  dimension: 24,
                  // Indeterminate until the first bytes arrive.
                  child: CircularProgressIndicator(value: p == 0 ? null : p, strokeWidth: 2, backgroundColor: scheme.surfaceContainerHighest),
                ),
                const Icon(PhosphorIcons.x, size: 12),
              ],
            ),
          ),
        _ => Padding(
            key: const ValueKey('done'),
            padding: const EdgeInsets.all(12),
            child: Tooltip(message: 'Downloaded', child: Icon(PhosphorIcons.checkCircleFill, color: scheme.onSurface)),
          ),
      },
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final OnlineVideo? video;
  final double width;
  final bool streaming, loading, showDuration;

  const _Thumbnail({required this.video, this.width = 96, this.streaming = false, this.loading = false, this.showDuration = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final thumbnail = video?.thumbnail;
    final duration = video?.durationText;
    Widget overlay(Widget child) => Container(color: Colors.black.withValues(alpha: 0.45), alignment: Alignment.center, child: child);

    return Container(
      width: width,
      height: width * 9 / 16,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(Constant.radiusSmall)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Icon(PhosphorIcons.youtubeLogo, size: width / 4, color: scheme.onSurfaceVariant),
          if (thumbnail != null)
            Image.network(
              thumbnail,
              fit: BoxFit.cover,
              cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          if (loading)
            overlay(const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
          else if (streaming)
            overlay(Icon(PhosphorIcons.waveform, size: width / 4, color: Colors.white)),
          if (showDuration && duration != null)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(4)),
                child: Text(duration, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

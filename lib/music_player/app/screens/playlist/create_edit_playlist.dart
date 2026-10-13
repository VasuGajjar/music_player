import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/music_player/music_player.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class CreateEditPlaylist extends StatefulWidget {
  final Playlist? playlist;

  const CreateEditPlaylist({Key? key, this.playlist}) : super(key: key);

  @override
  State<CreateEditPlaylist> createState() => _CreateEditPlaylistState();
}

class _CreateEditPlaylistState extends State<CreateEditPlaylist> {
  final _nameController = TextEditingController();
  List<Song> selectedSongs = [];

  @override
  void initState() {
    if (widget.playlist != null) {
      _nameController.text = widget.playlist!.name;
      selectedSongs.addAll(widget.playlist!.songs);
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void save() {
    if (widget.playlist == null) {
      context.read<PlaylistCubit>().createPlaylist(_nameController.text, selectedSongs).then((value) {
        if (mounted) Navigator.pop(context);
      });
    } else if (_nameController.text.trim().isNotEmpty) {
      context.read<PlaylistCubit>()
        ..changeName(widget.playlist!, _nameController.text)
        ..updatePlaylist(widget.playlist!, selectedSongs);
      Navigator.pop(context);
    }
  }

  void toggle(Song song) => setState(() => selectedSongs.contains(song) ? selectedSongs.remove(song) : selectedSongs.add(song));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist == null ? 'New playlist' : 'Edit playlist'),
        titleSpacing: 0,
        actions: [
          TextButton(onPressed: save, child: const Text('Save')),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _nameController,
              autofocus: widget.playlist == null,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.4),
              decoration: const InputDecoration(hintText: 'Playlist name'),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<MusicCubit, MusicState>(
              builder: (context, state) {
                if (state.songs.isEmpty) {
                  return const EmptyState(icon: PhosphorIcons.musicNote, text: 'No songs found');
                }

                return ListView.builder(
                  itemCount: state.songs.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final song = state.songs[index];
                    return MusicTile(
                      song: song,
                      onTap: () => toggle(song),
                      trailing: Checkbox(value: selectedSongs.contains(song), onChanged: (_) => toggle(song)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

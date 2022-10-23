import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/music_player/music_player.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist == null ? 'Add Playlist' : 'Edit Playlist'),
        actions: [
          IconButton(
            onPressed: () {
              if (widget.playlist == null) {
                context
                    .read<PlaylistCubit>()
                    .createPlaylist(
                      _nameController.text,
                      selectedSongs,
                    )
                    .then((value) => Navigator.pop(context));
              } else {
                if (_nameController.text.trim().isNotEmpty) {
                  context.read<PlaylistCubit>()
                    ..changeName(widget.playlist!, _nameController.text)
                    ..updatePlaylist(widget.playlist!, selectedSongs);
                  Navigator.pop(context);
                }
              }
            },
            icon: const Icon(PhosphorIcons.floppyDisk),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              style: TextStyles.h2Bold,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Name..',
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<MusicCubit, MusicState>(
              builder: (context, state) {
                if (state.songs.isEmpty) {
                  return const Center(
                    child: LottieWithText(
                      animation: Assets.noSongsAnimation,
                      text: 'No Songs Found',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: state.songs.length,
                  padding: const EdgeInsets.only(bottom: Constant.paddingMedium),
                  itemBuilder: (context, index) => musicTile(state.songs[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  musicTile(Song song) => ListTile(
        onTap: () => setState(() => selectedSongs.contains(song) ? selectedSongs.remove(song) : selectedSongs.add(song)),
        leading: SongCoverImage(song: song),
        title: Text(song.title, maxLines: 1),
        subtitle: Text(song.artist, maxLines: 1),
        trailing: Checkbox(
          value: selectedSongs.contains(song),
          onChanged: (value) => setState(() => value == true ? selectedSongs.add(song) : selectedSongs.remove(song)),
          shape: const CircleBorder(),
          activeColor: AppColor.darkPurple,
        ),
      );
}

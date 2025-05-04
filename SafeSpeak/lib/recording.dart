import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerFromAsset extends StatefulWidget {
  @override
  _AudioPlayerFromAssetState createState() => _AudioPlayerFromAssetState();
}

class _AudioPlayerFromAssetState extends State<AudioPlayerFromAsset> {
  final AudioPlayer _player = AudioPlayer();

  Future<void> _playAudio() async {
    try {
      // 👇 asset file se load aur play
      await _player.setAsset('assets/audio/Recording.m4a');
      _player.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Play Audio from Assets'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _playAudio,
          child: Text('Play Audio'),
        ),
      ),
    );
  }
}

import 'package:just_audio/just_audio.dart';

class SoundController {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _jumpPlayer = AudioPlayer();
  final AudioPlayer _hurtAndCollectPlayer = AudioPlayer();

  AudioSource jumpSound = AudioSource.asset('assets/sounds/sfxs/jump.mp3');
  AudioSource hurt = AudioSource.asset('assets/sounds/sfxs/ouch.mp3');
  AudioSource bite = AudioSource.asset('assets/sounds/sfxs/bite.mp3');
  AudioSource ring = AudioSource.asset('assets/sounds/sfxs/collect_ring.mp3');
  AudioSource poison = AudioSource.asset('assets/sounds/sfxs/poison.mp3');

  AudioSource intro = AudioSource.asset('assets/sounds/backgroundMusics/intro.mp3');
  AudioSource phase1 = AudioSource.asset('assets/sounds/backgroundMusics/phase1.mp3');
  AudioSource phase2 = AudioSource.asset('assets/sounds/backgroundMusics/phase2.mp3');

  SoundController() {
    _musicPlayer.setLoopMode(LoopMode.all);
    _musicPlayer.setVolume(0.4);
    _hurtAndCollectPlayer.setVolume(0.8);
    _jumpPlayer.setVolume(0.8);

    _hurtAndCollectPlayer.setAudioSource(hurt);
    _jumpPlayer.setAudioSource(jumpSound);
  }

  Future<void> musicBackgroundPlay({String when = 'Start'}) async {
    try {
      switch (when) {
        case 'Start':
          await _musicPlayer.stop();
          await _musicPlayer.setAudioSource(intro);
          await _musicPlayer.play();
          // print('play intro');
          break;
        case 'Phase1':
          await _musicPlayer.stop();
          await _musicPlayer.setAudioSource(phase1);
          await _musicPlayer.play();
          // print('play phase 1');
          break;
        case 'Phase2':
          await _musicPlayer.stop();
          await _musicPlayer.setAudioSource(phase2);
          await _musicPlayer.play();
          // print('play phase 2');
          break;
        default:
          await _musicPlayer.stop();
          await _musicPlayer.setAudioSource(intro);
          await _musicPlayer.play();
          // print('play default');
          break;
      }
    } catch (e) {
      print('Error music: $e');
    }
  }

  Future<void> jumpPlay() async {
    try {
      await _jumpPlayer.stop();
      await _jumpPlayer.setAudioSource(jumpSound);
      await _jumpPlayer.play();
    } catch (e) {
      print('Error jump: $e');
    }
  }

  Future<void> hurtAndCollectPlay({String when = 'Hurt'}) async {
    try {
      switch (when) {
        case 'Hurt':
          await _hurtAndCollectPlayer.stop();
          await _hurtAndCollectPlayer.setAudioSource(hurt);
          await _hurtAndCollectPlayer.play();
          break;

        case 'Collect':
          await _hurtAndCollectPlayer.stop();
          await _hurtAndCollectPlayer.setAudioSource(bite);
          await _hurtAndCollectPlayer.play();
          break;
        case 'Pass':
          await _hurtAndCollectPlayer.stop();
          await _hurtAndCollectPlayer.setAudioSource(ring);
          await _hurtAndCollectPlayer.play();
          break;
        case 'Poison':
          await _hurtAndCollectPlayer.stop();
          await _hurtAndCollectPlayer.setAudioSource(poison);
          await _hurtAndCollectPlayer.play();
          break;
        default:
          await _hurtAndCollectPlayer.stop();
          await _hurtAndCollectPlayer.setAudioSource(bite);
          await _hurtAndCollectPlayer.play();
          break;
      }
    } catch (e) {
      print('Error hurt: $e');
    }
  }

  Future<void> stopAll() async {
    try {
      await _musicPlayer.stop();
      await _jumpPlayer.stop();
      await _hurtAndCollectPlayer.stop();
    } catch (e) {
      print('Error Stop all: $e');
    }
  }

  Future<void> disposeAll() async {
    try {
      _musicPlayer.dispose();
      _jumpPlayer.dispose();
      _hurtAndCollectPlayer.dispose();
    } catch (e) {
      print('Error Dispose all: $e');
    }
  }
}

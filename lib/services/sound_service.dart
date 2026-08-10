import 'package:audioplayers/audioplayers.dart';

/// Shared audio context used for all in-app sound effects.
///
/// Configured so that app sounds NEVER interrupt or pause audio that is
/// already playing on the device (music, podcasts, etc.):
/// - Android: no audio focus is requested and other apps' focus requests
///   are ignored, so background playback continues untouched.
/// - iOS: "ambient" session category + mixWithOthers, so the sounds mix
///   over whatever else is playing instead of stopping it.
class AppSound {
  static final AudioContext context = AudioContext(
    android: AudioContextAndroid(
      audioMode: AudioMode.normal,
      audioFocus: AudioFocus.none,
      respectAudioFocus: false,
    ),
    ios: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
      options: {AVAudioSessionOptions.mixWithOthers},
    ),
  );
}
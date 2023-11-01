import 'package:get/get.dart';
import 'package:music_player/controller/SongPlayerController.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class SongDataController extends GetxController {
  SongPlayerController songPlayerController = Get.put(SongPlayerController());
  final audioQuery = OnAudioQuery();

  RxList<SongModel> localSongList = <SongModel>[].obs;
  RxBool isDeviceSong = false.obs;
  RxInt currentSongPlayingIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    storagePermission();
  }

  void getLocalSongs() async {
    localSongList.value = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );
  }

  void storagePermission() async {
    try {
      var perm = await Permission.storage.request();
      if (perm.isGranted) {
        print('Permission granted');
        getLocalSongs();
      } else {
        print('Permission denied');
        await Permission.storage.request();
      }
    } catch (ex) {
      print(ex);
    }
  }

  void findCurrentSongPlayingIndex(int songId) {
    var index = 0;
    localSongList.forEach((e) {
      if (e.id == songId) {
        currentSongPlayingIndex.value = index;
      }

      index++;
    });

    print(songId);
    print(currentSongPlayingIndex);
  }

  void playNextSong() {
    int songListLen = localSongList.length;
    currentSongPlayingIndex.value = currentSongPlayingIndex.value + 1;

    if (currentSongPlayingIndex.value < songListLen) {
      SongModel nextSong = localSongList[currentSongPlayingIndex.value];
      songPlayerController.playLocalAudio(nextSong);
    }
  }

  void playPreviousSong() {
    int songListLen = localSongList.length;
    print(currentSongPlayingIndex.value);
    if (currentSongPlayingIndex.value != 0) {
      currentSongPlayingIndex.value = --currentSongPlayingIndex.value;
      if (currentSongPlayingIndex.value < songListLen) {
        SongModel nextSong = localSongList[currentSongPlayingIndex.value];
        songPlayerController.playLocalAudio(nextSong);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:muisicp/constants/colors.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/text_style.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    final permStatus = await Permission.storage.status;
    if (permStatus.isDenied) {
      final perm = await Permission.storage.request();
      if (perm.isDenied) {
        if (perm.isPermanentlyDenied) {
          openAppSettings();
        } else {
          checkPermission();  // Recheck permission if denied
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: MyText(
          'Tunes',
          color: wColor,
        ),
      ),

      body: FutureBuilder<List<SongModel>>(
        future: audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: MyText(snapshot.data![index].displayNameWOExt),
                  subtitle: MyText(snapshot.data![index].artist ?? 'Unknown Artist'), // Handling null artist
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: MyText('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: MyText("No Music Found"),
            );
          }
        },
      ),
    );
  }
}

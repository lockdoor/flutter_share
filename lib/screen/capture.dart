import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_share/models/share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Capture {
  static Future<void> shareCaptureWidget(
      Uint8List imageBytes, ShareModel shareModel) async {
    //await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '_')
        .replaceAll(':', '-');
    final name = shareModel.name + time;
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/$name.jpg');
    image.writeAsBytesSync(imageBytes);
    print(image);
    await Share.shareFiles([image.path]);
  }
}

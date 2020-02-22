import 'dart:convert';
import 'dart:html';

import 'package:HolySheetWeb/src/constants.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:HolySheetWeb/src/services/file_service.dart';
import 'package:angular/core.dart';

@Injectable()
class FileSendService {
  final AuthService authService;
  final FileService fileService;

  FileSendService(this.authService, this.fileService);

  void send(File file, String path, {Function(double) onProgress, Function() onDone}) {
    var ws = WebSocket('$WEBSOCKET_PROTOCOL://$API_URL/upload?Authorization=${authService.accessToken}&name=${file.name}&length=${file.size}&path=${Uri.encodeComponent(path)}');

    ws.onClose.listen((event) {
      final code = event.code;
      final reason = event.reason;

      if (code == 1000) {
        var status = jsonDecode(reason);
        if (status['status'] == 'done') {
          print('Done with upload!');
        } else {
          print('Non-done status successfully closed websocket: $status');
        }
      } else if (code == 1009) {
        print('Message too large. Close response:');
        print(reason);
      } else if (code != 1011) {
        final json = jsonDecode(reason);
        print('Closed upload websocket with an Internal Server Error (1011). Error:\n${json['error']}\nStacktrace:\n${json['stacktrace']}');
      } else if (code != 1000) {
        print('Unknown close response "$reason" with code $code');
      }

      onDone?.call();
    });

    var size = file.size;
    var sliceSize = 4000000; // 4MB due to gRPC restrictions
    var start = 0;

    void sendChunk() {
      var end = start + sliceSize;

      if (size - end < 0) {
        end = size;
      }

      ws.sendBlob(file.slice(start, end));

      if (end < size) {
        start += sliceSize;
        return;
      }
    }

    ws.onMessage.listen((event) {
      final json = jsonDecode(event.data);
      if (json['status'] == 'ok') {
        var progress = json['progress'];
        print('Upload progress: $progress');
        onProgress?.call(progress);
        sendChunk();
      } else {
        print('Invalid response, recieved:\n$json');
      }
    });
  }

  Blob slice(File file, start, end) => file.slice(start, end);
}

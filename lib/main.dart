import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];
  String url = 'https://www.gameyoutube.com/watch?v=u0fHCUj7kP4';

  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(
      Uri.parse('https://www.gameyoutube.com/watch?v=u0fHCUj7kP4'),
    );

  @override
  void initState() {
    super.initState();
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      setState(
        () {
          _sharedFiles.clear();
          _sharedFiles.addAll(value);
          log(
            _sharedFiles.map((f) => f.toMap()).toString(),
          );
        },
      );
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    ReceiveSharingIntent.instance.getInitialMedia().then(
      (value) {
        log(
          value.length.toString(),
        );
        setState(
          () {
            _sharedFiles.clear();
            _sharedFiles.addAll(value);
            if (_sharedFiles.isNotEmpty)
              controller.loadRequest(
                Uri.parse('https://www.gameyoutube.com/watch?v=' +
                    "${_sharedFiles.first.path.replaceAll('https://youtube.com/watch?v=', '')}"),
              );
            ReceiveSharingIntent.instance.reset();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textStyleBold = const TextStyle(fontWeight: FontWeight.bold);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: const Text('Quiz App'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text("Shared files: ${_sharedFiles.length}",
                  style: textStyleBold),
              Expanded(
                child: ListView.builder(
                  itemCount: _sharedFiles.length,
                  itemBuilder: (context, index) {
                    SharedMediaFile sharedFile = _sharedFiles[index];
                    return SizedBox(
                      height: 800,
                      width: 300,
                      child: WebViewWidget(controller: controller),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

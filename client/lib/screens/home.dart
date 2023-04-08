import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:frontend/components/bottom_nav.dart';
import 'package:frontend/components/bounding_box.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? image;
  int? value;
  List<BBox>? boundingBoxes;
  String url = 'http://10.0.2.2:5000';
  ui.Size? imageSize;
  late TextEditingController _controller;

  GlobalKey key = GlobalKey();
  final GlobalKey picKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setSize() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BuildContext? box = key.currentContext;
      ui.Size? size;
      if (box != null) {
        RenderBox renderBox = box.findRenderObject() as RenderBox;
        size = renderBox.size;
      } else {
        size = null;
      }
      setState(() => {imageSize = size});
    });
  }

  Image getImage() {
    if (image != null) {
      return Image.file(
        key: key,
        image!,
      );
    } else {
      return Image.asset(
        'assets/images/c2g_logo.jpeg',
        key: key,
      );
    }
  }

  Future<void> takePicture() async {
    BuildContext? context = picKey.currentContext;
    final RenderRepaintBoundary boundary =
        context!.findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    final directory = (await getTemporaryDirectory()).path;
    File imgFile = File('$directory/photo.png');

    await imgFile.writeAsBytes(pngBytes);
    imgFile = File(imgFile.path);
    await GallerySaver.saveImage(imgFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Count your coins!')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RepaintBoundary(
                  key: picKey,
                  child: Stack(
                    children: [
                      getImage(),
                      if (imageSize != null && boundingBoxes != null)
                        for (var box in boundingBoxes!)
                          BoundingBox(
                            box: box,
                            imageSize: imageSize!,
                          )
                    ],
                  ),
                )),
          ),
          if (value != null)
            Text('Calculated Value: ${value! / 100} €',
                style: const TextStyle(
                  fontSize: 24,
                )),
          if (boundingBoxes != null)
            Text('Number of Coins: ${boundingBoxes!.length}',
                style: const TextStyle(
                  fontSize: 24,
                )),
          TextField(
            controller: _controller,
            onSubmitted: (String value) {
              setState(() => {url = value});
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'URL for API Endpoint, e.g. $url',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () async {
                    if (await Permission.camera.request().isGranted) {
                      pickImage(ImageSource.camera);
                    }
                  },
                  iconSize: 48,
                  icon: const Icon(Icons.camera_alt)),
              IconButton(
                  onPressed: () =>
                      pickImage(ImageSource.gallery, saveImg: false),
                  iconSize: 48,
                  icon: const Icon(Icons.photo_library)),
              IconButton(
                  onPressed: () => takePicture(),
                  iconSize: 48,
                  icon: const Icon(Icons.save_alt)),
            ],
          )
        ],
      ),
      bottomNavigationBar: const BottomNav(0),
    );
  }

  Future pickImage(ImageSource source, {bool saveImg = true}) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      if (saveImg) {
        await GallerySaver.saveImage(image.path);
      }

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() => {
              this.image = File(croppedFile.path),
              boundingBoxes = null,
              value = null
            });
        sendImageToServer(File(croppedFile.path));
      }
    } on PlatformException catch (e) {
      debugPrint('Not allowed to get picture: $e.');
    }
  }

  Future sendImageToServer(File imageFile) async {
    final Uint8List asd = await imageFile.readAsBytes();
    final String imgStr = base64Encode(Uint8List.fromList(asd));
    final Uri uri = Uri.parse(url);
    final http.Response response =
        await http.post(uri, body: json.encode({'image': imgStr}));

    if (response.statusCode == 200) {
      dynamic body = json.decode(response.body);

      List<BBox> boxes = [];
      for (dynamic ele in body['bounding_boxes']) {
        dynamic box = ele['box'];
        boxes.add(BBox(box[0], box[1], box[2], box[3], ele['text']));
      }

      setState(() => {value = body['value'], boundingBoxes = boxes});
      setSize();
    }
  }
}

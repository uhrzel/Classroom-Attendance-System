import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/services.dart';

class GenerateQRScreen extends StatefulWidget {
  @override
  _GenerateQRScreenState createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  TextEditingController studentIdController = TextEditingController();
  String? qrData;

  Future<String?> saveQrCodeToGallery(String qrCode) async {
    try {
      final QrPainter painter = QrPainter(
        data: qrCode,
        version: QrVersions.auto,
        gapless: false,
        color: Colors.black, // QR code color
        emptyColor: Colors.transparent, // Background color
      );
      final ByteData data =
          await painter.toImageData(500, format: ImageByteFormat.png);
      final Uint8List bytes = data.buffer.asUint8List();

      // Manually adding white background to the QR code image
      final ui.Image image = await decodeImageFromList(bytes);
      final ui.Image whiteBackgroundImage =
          await createWhiteBackgroundImage(image);

      // Convert the image to byte data
      final ByteData? whiteBackgroundData =
          await whiteBackgroundImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List? whiteBackgroundBytes =
          whiteBackgroundData?.buffer.asUint8List();

      // Save the image with a white background
      await ImageGallerySaver.saveImage(whiteBackgroundBytes!,
          name: 'QR_Code_$qrCode');
      return qrCode; // Return the entered student ID after saving
    } catch (e) {
      print("Error saving QR code: $e");
      return null;
    }
  }

  // Function to create an image with a white background
  Future<ui.Image> createWhiteBackgroundImage(ui.Image originalImage) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw a white background
    canvas.drawRect(
        Rect.fromLTWH(0.0, 0.0, originalImage.width.toDouble(),
            originalImage.height.toDouble()),
        Paint()..color = Colors.white);

    // Draw the original image on top of the white background
    canvas.drawImage(originalImage, Offset.zero, Paint());

    return recorder.endRecording().toImage(
          originalImage.width,
          originalImage.height,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: studentIdController,
          decoration: InputDecoration(
            labelText: "Enter student ID",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              qrData = studentIdController.text;
            });
          },
          child: Text("Generate QR Code"),
        ),
        SizedBox(height: 16),
        if (qrData != null) ...[
          QrImage(
            data: qrData!,
            version: QrVersions.auto,
            size: 200.0,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              String? enteredId = await saveQrCodeToGallery(qrData!);
              if (enteredId != null) {
                Navigator.pop(context, enteredId);
              }
            },
            child: Text("Save QR Code"),
          ),
        ],
      ],
    );
  }
}

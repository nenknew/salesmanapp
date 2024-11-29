import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

class MiscUtils {
  static Future<Uint8List> resizeImage(String base64Image, int targetWidth, int targetHeight) async {
    // Decode the base64 image string to bytes
    Uint8List bytes = base64.decode(base64Image);

    // Create an Image object from the bytes
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image image = frameInfo.image;

    // Create a new PictureRecorder
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(recorder);

    // Calculate the scale factor for resizing
    double scaleWidth = targetWidth / image.width;
    double scaleHeight = targetHeight / image.height;

    // Create a source Rect for the image to be drawn
    ui.Rect srcRect = ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

    // Create a destination Rect for the image with the new size
    ui.Rect destRect = ui.Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble());

    // Draw the image onto the canvas with the new size
    canvas.drawImageRect(image, srcRect, destRect, ui.Paint());

    // Finalize the recording and convert it into an Image
    ui.Picture picture = recorder.endRecording();
    ui.Image resizedImage = await picture.toImage(targetWidth, targetHeight);

    // Convert the resized image to bytes
    ByteData? byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List resizedBytes = byteData!.buffer.asUint8List();

    return resizedBytes;
  }
}

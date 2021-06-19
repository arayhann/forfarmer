import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forfarmer/pages/plant_detected_page.dart';
import 'package:tflite/tflite.dart';

class ImagePopUp extends HookWidget {
  final File croppedFile;

  const ImagePopUp({Key? key, required this.croppedFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isLoadingRecognize = useState(false);
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.file(
            croppedFile,
          ),
          const SizedBox(
            height: 20,
          ),
          Text('Gunakan foto ini?'),
          const SizedBox(
            height: 20,
          ),
          _isLoadingRecognize.value
              ? Center(child: CircularProgressIndicator())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Ink(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(0xFFDF5529),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Tidak',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () async {
                        _isLoadingRecognize.value = true;

                        var recognitions = await Tflite.runModelOnImage(
                          path: croppedFile.path, // required
                          imageMean: 0.0, // defaults to 117.0
                          imageStd: 255.0, // defaults to 1.0
                          threshold: 0.2,
                        );

                        if (recognitions == null) {
                          return;
                        }

                        if (recognitions.isEmpty) {
                          return;
                        }

                        _isLoadingRecognize.value = false;

                        print('result =======> $recognitions');

                        Navigator.of(context).pop();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantDetectedPage(
                              recognitions: recognitions,
                            ),
                          ),
                        );
                      },
                      child: Ink(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(0xFF72BF00),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Ya',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

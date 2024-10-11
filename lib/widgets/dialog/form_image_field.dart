import 'dart:io';

import 'package:flutter/material.dart';
import 'package:general_pos/widgets/icon_button.dart';
import 'package:image_picker/image_picker.dart';

class DialogImageInputField extends StatelessWidget {
  final XFile? imagePath;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final ValueNotifier<XFile?> imageNotifier;

  const DialogImageInputField({
    super.key,
    required this.imagePath,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.imageNotifier
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<XFile?>(
      valueListenable: imageNotifier,
      builder: (context, imagePath, child) {
        return SizedBox(
          height: 230,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: imagePath == null ? Colors.black12 : null,
              image: imagePath == null ? null : DecorationImage(
                image: FileImage(File(imagePath.path)),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    AppIconButton(
                      onPressed: () => onCameraTap(),
                      icon: Icons.camera
                    ),
                    const SizedBox(width: 10),
                    AppIconButton(
                      onPressed: () => onGalleryTap(),
                      icon: Icons.file_open
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

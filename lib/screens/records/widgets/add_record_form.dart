import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:general_pos/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../widgets/dialog/form_image_field.dart';
import '../../../../widgets/dialog/form_text_field.dart';
import '../../../../widgets/dialog/form_dialog.dart';
import '../../../constants.dart';

class AddRecordForm extends StatefulWidget {
  final void Function({ String? searchName }) refreshRecord;
  const AddRecordForm({super.key, required this.refreshRecord});

  @override
  AddRecordFormState createState() => AddRecordFormState();
}

class AddRecordFormState extends State<AddRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  XFile? _imagePath;
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<XFile?> _imageNotifier = ValueNotifier<XFile?>(null);
  String? _imageFileName;

  Future<void> _pickImage(ImageSource source) async {
    XFile? newImage;

    if (source == ImageSource.camera) {
      newImage = await _picker.pickImage(
        source: source,
        maxHeight: 720,
        maxWidth: 1280,
      );
    }

    if (source == ImageSource.gallery) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        newImage = XFile(result.files.single.path!);
      }
    }

    if (newImage != null) {
      // Check if a previous image exists and delete it
      if (_imagePath != null) {
        final previousImagePath = _imagePath!.path;
        final previousImageFile = File(previousImagePath);

        if (await previousImageFile.exists()) {
          await previousImageFile.delete();
        }
      }

      // Update the notifier and imagePath
      _imageNotifier.value = newImage;
      _imagePath = newImage;

      // Save the new image to the app downloads directory
      _imageFileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      await newImage.saveTo('${await productImageDirectory()}/$_imageFileName');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }

    if (_imageFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an image')),
      );
    }

    Product product = Product(
        id: const Uuid().v4(),
        imageFileName: _imageFileName!,
        quantity: int.parse(_quantityController.text),
        name: _nameController.text,
        price: double.parse(_priceController.text)
    );

    product.create();

    _nameController.clear();
    _quantityController.clear();
    _priceController.clear();
    _imageNotifier.value = null;

    widget.refreshRecord();

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully!')),
    );
  }

  _pickFromCamera() => _pickImage(ImageSource.camera);
  _pickFromGallery() => _pickImage(ImageSource.gallery);

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      formKey: _formKey,
      title: 'Add New Product',
      inputFields: [
        DialogImageInputField(
          imageNotifier: _imageNotifier,
          imagePath: _imagePath,
          onCameraTap: _pickFromCamera,
          onGalleryTap: _pickFromGallery,
        ),
        FormTextField(
          icon: Icons.tag,
          controller: _nameController,
          label: 'Name',
        ),
        FormTextField(
          icon: Icons.inventory,
          controller: _quantityController,
          label: 'Quantity',
          keyboardType: TextInputType.number,
        ),
        FormTextField(
          icon: Icons.price_check,
          controller: _priceController,
          label: 'Price',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
      onSubmit: _submitForm,
      submitButtonText: 'Add Product',
    );
  }
}

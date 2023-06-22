import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_demo/data/dbHelper.dart';
import 'package:sqflite_demo/validation/product_validator.dart';

import '../models/product.dart';

class ProductAdd extends StatefulWidget {
  const ProductAdd({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> with ProductValidator {
  final dbHelper = DbHelper();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final descriptionController = TextEditingController();
  final unitPriceController = TextEditingController();
  var imagePath = "";
  var errorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Yeni ürün ekle"),
      ),
      body: SingleChildScrollView(
        dragStartBehavior: DragStartBehavior.start,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                buildImagePickerButton(),
                const SizedBox(height: 10),
                Text(
                  errorText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                  ),
                ),
                buildNameField(),
                buildBrandField(),
                buildDescriptionField(),
                buildUnitPriceField(),
                buildAddButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagePickerButton() {
    return imagePath.isNotEmpty
        ? SizedBox(
      width: 200,
      height: 200,
      child: GestureDetector(
        onLongPress: (){
          setState(() {
            imagePath = "";
          });
        },
        onTap: pickImage,
        onDoubleTap: (){
        },
        child: Image.file(File(imagePath)),
      ),
    )
        : FloatingActionButton(
      onPressed: pickImage,
      tooltip: "Resim Yükle",
      child: const Icon(Icons.image),
    );
  }

  TextFormField buildNameField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      validator: validateNameField,
      controller: nameController,
      decoration: const InputDecoration(labelText: "Ürün Adı"),
    );
  }

  TextFormField buildBrandField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      validator: validateBrandField,
      controller: brandController,
      decoration: const InputDecoration(labelText: "Ürün Markası"),
    );
  }

  TextFormField buildDescriptionField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      validator: validateDescriptionField,
      controller: descriptionController,
      maxLines: null,
      decoration: const InputDecoration(labelText: "Ürün Açıklaması",alignLabelWithHint: true),
    );
  }

  TextFormField buildUnitPriceField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      validator: validateUnitPrice,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
      ],
      controller: unitPriceController,
      decoration: const InputDecoration(labelText: "Ürün Fiyatı", hintText: '0.00'),
    );
  }

  TextButton buildAddButton() {
    return TextButton(
      onPressed: () {
        if (imagePath.isEmpty) {
          setState(() {
            errorText = "Lütfen bir resim seçin.";
          });
        } else {
          addProduct();
        }
      },
      child: const Text("Ekle"),
    );
  }

  void addProduct() async {
    if(_formKey.currentState!.validate()){
      await saveImage(File(imagePath)).then((value) async {
        var result = await dbHelper.add(
          Product(
            nameController.text.trim(),
            brandController.text.trim(),
            descriptionController.text.trim(),
            double.tryParse(unitPriceController.text.trim())!,
            imagePath.trim(),
          ),
        );
        Future.delayed(Duration.zero, () {
          Navigator.pop(context, result);
        });
      });
    }
  }

  void pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
        errorText = "";
      });
    }
  }

  Future<String> saveImage(File imageFile) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String fileName = '${DateTime.now().millisecondsSinceEpoch}-${nameController.text.trim().replaceAll(" ","-").replaceAll(".", "_")}.jpg';
    String filePath = '${appDir.path}/$fileName';
    await imageFile.copy(filePath);
    return filePath;
  }
}

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_demo/validation/product_validator.dart';

import '../data/dbHelper.dart';
import '../models/product.dart';

class ProductDetail extends StatefulWidget {
  final Product product;
  const ProductDetail(this.product, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ProductDetailState();
  }
}

class _ProductDetailState extends State<ProductDetail> with ProductValidator {
  final dbHelper = DbHelper();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final descriptionController = TextEditingController();
  final unitPriceController = TextEditingController();
  var imagePath = "";
  late Product product;
  @override
  void initState() {
    super.initState();
    product = widget.product;
    nameController.text = product.name;
    brandController.text = product.brand;
    descriptionController.text = product.description;
    unitPriceController.text = product.unitPrice.toString();
    imagePath = product.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(product.name)),
      ),
      body: buildProductDetail(),
    );
  }

  Widget buildProductDetail() {
    return SingleChildScrollView(
      dragStartBehavior: DragStartBehavior.start,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              buildImageField(),
              buildNameField(),
              buildBrandField(),
              buildDescriptionField(),
              buildUnitPriceField(),
              buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImageField() {
    return SizedBox(
      width: 200,
      height: 200,
      child: GestureDetector(
        onTap: pickImage,
        child: Image.file(File(imagePath)),
      ),
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
      decoration: const InputDecoration(
          labelText: "Ürün Açıklaması", alignLabelWithHint: true),
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
      decoration:
          const InputDecoration(labelText: "Ürün Fiyatı", hintText: '0.00'),
    );
  }

  TextButton buildUpdateButton() {
    return TextButton(
      onPressed: () {
          updateProduct();
      },
      child: const Text("Güncelle"),
    );
  }

  void updateProduct() async {
    if (_formKey.currentState!.validate()) {
      await saveImage(File(imagePath)).then((value) async {
        var result = await dbHelper.update(
          Product.allArgs(
            product.id,
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
    var pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<String?> saveImage(File imageFile) async {
    if(imageFile.path == product.imagePath) return null;
    Directory appDir = await getApplicationDocumentsDirectory();
    String fileName =
        '${DateTime.now().millisecondsSinceEpoch}-${nameController.text.trim().replaceAll(" ", "-").replaceAll(".", "_")}.jpg';
    String filePath = '${appDir.path}/$fileName';
    await imageFile.copy(filePath);
    return filePath;
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_demo/data/dbHelper.dart';
import 'package:sqflite_demo/screens/product_add.dart';
import 'package:sqflite_demo/screens/product_detail.dart';

import '../models/product.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductListState();
  }
}

class _ProductListState extends State<ProductList> {
  var dbHelper = DbHelper();
  List<Product> products = [];
  late int productCount = 0;

  @override
  void initState()
  {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ürün Listesi"),
      ),
      body: buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          goToProductAdd();
        },
        tooltip: "Yeni ürün ekle",
        child: const Icon(Icons.add),
      ),
    );
  }

  ListView buildProductList() {
    return ListView.builder(
        itemCount: productCount,
        itemBuilder: (BuildContext context, int index)
        {
          var currentProduct = products[index];
          return Card(
            color: Colors.cyan,
            child: ListTile(
              onTap: () {
                goToProductDetail(currentProduct);
              },
              onLongPress: (){
                showDeleteConfirmationDialog(currentProduct);
              },
              subtitle: Text(currentProduct.description),
              title: Text("${currentProduct.brand} ${currentProduct.name}"),
              leading: CircleAvatar(
                backgroundColor: Colors.black38,
                radius: 27,
                backgroundImage: FileImage(File(currentProduct.imagePath)),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top:25.0),
                child: Text("${currentProduct.unitPrice.toString()} TL"),
              ),
            ),
          );
        });
  }
  void showDeleteConfirmationDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ürünü Sil'),
          content: Text('${product.brand} ${product.name} ürününü silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Color(Colors.black54.value))
              ),
              child: const Text('İptal'),
              onPressed: () {
                Navigator.pop(context); // İletişim kutusunu kapat
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () {
                deleteProduct(product.id!);
                Navigator.pop(context); // İletişim kutusunu kapat
              },
            ),
          ],
        );
      },
    );
  }
  void goToProductAdd() async {
    var result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ProductAdd()));
    if (result != null) {
        getProducts();
    }
  }
  void deleteProduct(int id) async{
    var result = await dbHelper.delete(id);
    if(result != null){
        getProducts();
    }
  }
  void getProducts() async {
    var products = await dbHelper.getAll();
    setState(() {
      this.products = products;
      productCount = products.length;
    });
  }

  void goToProductDetail(Product currentProduct) async{
    var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetail(currentProduct)));
    if(result != null) {
      getProducts();
    }
  }
}

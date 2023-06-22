import 'package:sqflite_demo/constants/ProductMessages.dart';

class ProductValidator{

  String? validateNameField(String? value){
    if(value!.length < 2){
      return ProductMessages.nameLengthMustBeAtLeastTwoCharacters;
    }
    return null;
  }
  String? validateBrandField(String? value){
    if(value!.length < 2){
      return ProductMessages.brandLengthMustBeAtLeastTwoCharacters;
    }
    return null;
  }
  String? validateDescriptionField(String? value){
    if(value!.length < 10){
      return ProductMessages.descriptionLengthMustBeAtLeastTenCharacters;
    }
    return null;
  }

  String? validateUnitPrice(String? value){
    if(value!.isEmpty) value = "0.00";
    if(double.tryParse(value)! <= 0){
      return ProductMessages.unitPriceMustBeGreaterThanZero;
    }
    return null;
  }
}
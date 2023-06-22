    class Product{
        late int? id = 0;
        late String name;
        late String brand;
        late String description;
        late double unitPrice;
        late String imagePath;

        Product.allArgs(this.id,this.name,this.brand,this.description,this.unitPrice,this.imagePath);
        Product(this.name,this.brand,this.description,this.unitPrice,this.imagePath);
        Product.fromObject(dynamic o){
            id = int.tryParse(o["id"].toString());
            name = o["name"];
            brand = o["brand"];
            description = o["description"];
            unitPrice = double.tryParse(o["unitPrice"].toString())!;
            imagePath = o["imagePath"];
        }
        Map<String, dynamic> toMap(){
            var map = <String,dynamic>{};
            id ??= map["id"] = (id);
            map["name"] = name;
            map["brand"] = brand;
            map["description"] = description;
            map["unitPrice"] = unitPrice;
            map["imagePath"] = imagePath;
            return map;
        }
    }
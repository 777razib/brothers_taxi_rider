class Vehicle {
  final String? id;
  final String? manufacturer;
  final String? model;
  final String? licensePlateNumber;
  final String? bh;
  final String? image;
  final String? color;
  final Driver? driver;

  Vehicle({
    this.id,
    this.manufacturer,
    this.model,
    this.licensePlateNumber,
    this.bh,
    this.image,
    this.color,
    this.driver,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json["id"],
      manufacturer: json["manufacturer"],
      model: json["model"],
      licensePlateNumber: json["licensePlateNumber"],
      bh: json["bh"],
      image: json["image"],
      color: json["color"],
      driver: json["driver"] != null ? Driver.fromJson(json["driver"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "manufacturer": manufacturer,
      "model": model,
      "licensePlateNumber": licensePlateNumber,
      "bh": bh,
      "image": image,
      "color": color,
      "driver": driver?.toJson(),
    };
  }
}

class Driver {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? profileImage;
  final String? location;

  Driver({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.location,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json["id"],
      fullName: json["fullName"],
      email: json["email"],
      phoneNumber: json["phoneNumber"],
      profileImage: json["profileImage"],
      location: json["location"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "profileImage": profileImage,
      "location": location,
    };
  }
}

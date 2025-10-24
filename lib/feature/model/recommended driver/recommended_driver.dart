class RecommendedDriver {
  final String? id;
  final String? fullName;
  final String? phone;
  final String? profileImage;
  final double? lat;
  final double? lng;
  final double? distanceFromPickup;

  RecommendedDriver({
    this.id,
    this.fullName,
    this.phone,
    this.profileImage,
    this.lat,
    this.lng,
    this.distanceFromPickup,
  });

  factory RecommendedDriver.fromJson(Map<String, dynamic> json) {
    return RecommendedDriver(
      id: json["id"],
      fullName: json["fullName"],
      phone: json["phone"],
      profileImage: json["profileImage"],
      lat: (json["lat"] as num?)?.toDouble(),
      lng: (json["lng"] as num?)?.toDouble(),
      distanceFromPickup: (json["distanceFromPickup"] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "phone": phone,
      "profileImage": profileImage,
      "lat": lat,
      "lng": lng,
      "distanceFromPickup": distanceFromPickup,
    };
  }
}

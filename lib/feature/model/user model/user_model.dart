class User {
  final String? id;
  final String? fullName;
  final String? email;
  final String? profileImage;
  final String? location;
  final double? lat;
  final double? lng;

  User({
    this.id,
    this.fullName,
    this.email,
    this.profileImage,
    this.location,
    this.lat,
    this.lng,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      fullName: json["fullName"],
      email: json["email"],
      profileImage: json["profileImage"],
      location: json["location"],
      lat: (json["lat"] as num?)?.toDouble(),
      lng: (json["lng"] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "profileImage": profileImage,
      "location": location,
      "lat": lat,
      "lng": lng,
    };
  }
}

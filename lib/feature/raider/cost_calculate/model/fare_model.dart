class FareModel {
  final String id;
  final String? userId;
  final String? pickup;
  final String? dropOff;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropOffLat;
  final double? dropOffLng;
  final double? distance;      // in km
  final double? totalFare;
  final double baseFare;
  final double costPerKm;
  final double costPerMin;
  final double minimumFare;
  final double waitingPerMin;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FareModel({
    required this.id,
    this.userId,
    this.pickup,
    this.dropOff,
    this.pickupLat,
    this.pickupLng,
    this.dropOffLat,
    this.dropOffLng,
    this.distance,
    this.totalFare,
    required this.baseFare,
    required this.costPerKm,
    required this.costPerMin,
    required this.minimumFare,
    required this.waitingPerMin,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// From JSON → Model
  factory FareModel.fromJson(Map<String, dynamic> json) {
    return FareModel(
      id: json["id"] ?? "",
      userId: json["userId"],
      pickup: json["pickup"],
      dropOff: json["dropOff"],
      pickupLat: (json["pickupLat"] ?? 0).toDouble(),
      pickupLng: (json["pickupLng"] ?? 0).toDouble(),
      dropOffLat: (json["dropOffLat"] ?? 0).toDouble(),
      dropOffLng: (json["dropOffLng"] ?? 0).toDouble(),
      distance: (json["distance"] ?? 0).toDouble(),
      totalFare: (json["totalFare"] ?? 0).toDouble(),
      baseFare: (json["baseFare"] ?? 0).toDouble(),
      costPerKm: (json["costPerKm"] ?? 0).toDouble(),
      costPerMin: (json["costPerMin"] ?? 0).toDouble(),
      minimumFare: (json["minimumFare"] ?? 0).toDouble(),
      waitingPerMin: (json["waitingPerMin"] ?? 0).toDouble(),
      isActive: json["isActive"] ?? false,
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),
    );
  }

  /// To JSON → Model
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "pickup": pickup,
      "dropOff": dropOff,
      "pickupLat": pickupLat,
      "pickupLng": pickupLng,
      "dropOffLat": dropOffLat,
      "dropOffLng": dropOffLng,
      "distance": distance,
      "totalFare": totalFare,
      "baseFare": baseFare,
      "costPerKm": costPerKm,
      "costPerMin": costPerMin,
      "minimumFare": minimumFare,
      "waitingPerMin": waitingPerMin,
      "isActive": isActive,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class CalculatedFareModel {
  final double? totalFare;
  final double? distance;
  final int? duration;
  final double? baseFare;
  final double? costPerKm;
  final double? costPerMin;
  final double? minimumFare;
  final double? waitingPerMin;
  final String? pickup;
  final String? dropOff;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropOffLat;
  final double? dropOffLng;

  CalculatedFareModel({
    this.totalFare,
    this.distance,
    this.duration,
    this.baseFare,
    this.costPerKm,
    this.costPerMin,
    this.minimumFare,
    this.waitingPerMin,
    this.pickup,
    this.dropOff,
    this.pickupLat,
    this.pickupLng,
    this.dropOffLat,
    this.dropOffLng,
  });

  factory CalculatedFareModel.fromJson(Map<String, dynamic> json) {
    // Handle the actual API response structure
    return CalculatedFareModel(
      totalFare: (json["totalFare"] ?? 0).toDouble(),
      distance: double.tryParse(json["distance"]?.toString() ?? "0") ?? 0.0,
      duration: json["duration"] ?? 0,
      baseFare: (json["baseFare"] ?? 0).toDouble(),
      costPerKm: (json["costPerKm"] ?? 0).toDouble(),
      costPerMin: (json["costPerMin"] ?? 0).toDouble(),
      minimumFare: (json["minimumFare"] ?? 0).toDouble(),
      waitingPerMin: (json["waitingPerMin"] ?? 0).toDouble(),
      pickup: json["pickup"],
      dropOff: json["dropOff"],
      pickupLat: json["pickupLocation"]?["lat"]?.toDouble() ?? 0.0,
      pickupLng: json["pickupLocation"]?["lng"]?.toDouble() ?? 0.0,
      dropOffLat: json["dropOffLocation"]?["lat"]?.toDouble() ?? 0.0,
      dropOffLng: json["dropOffLocation"]?["lng"]?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "totalFare": totalFare,
      "distance": distance,
      "duration": duration,
      "baseFare": baseFare,
      "costPerKm": costPerKm,
      "costPerMin": costPerMin,
      "minimumFare": minimumFare,
      "waitingPerMin": waitingPerMin,
      "pickup": pickup,
      "dropOff": dropOff,
      "pickupLat": pickupLat,
      "pickupLng": pickupLng,
      "dropOffLat": dropOffLat,
      "dropOffLng": dropOffLng,
    };
  }
}

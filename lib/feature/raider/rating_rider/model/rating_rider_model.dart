import 'dart:convert';

/// Helper function to decode a JSON string into a [RatingRiderModel] object.
RatingRiderModel ratingRiderModelFromJson(String str) =>
    RatingRiderModel.fromJson(json.decode(str) as Map<String, dynamic>);

/// Helper function to encode a [RatingRiderModel] object into a JSON string.
String ratingRiderModelToJson(RatingRiderModel data) => json.encode(data.toJson());

class RatingRiderModel {
  final String? id;
  final String? carTransportId;
  final int? rating;
  final String? comment;

  RatingRiderModel({
    this.id,
    this.carTransportId,
    this.rating,
    this.comment,
  });

  /// Factory constructor to create a [RatingRiderModel] instance from a JSON map.
  factory RatingRiderModel.fromJson(Map<String, dynamic> json) {
    return RatingRiderModel(
      // --- FIXED: Added 'id' parsing ---
      id: json['id'] as String?,
      carTransportId: json['carTransportId'] as String?,
      rating: json['rating'] as int?,
      comment: json['comment'] as String?,
    );
  }

  /// Converts the [RatingRiderModel] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      // --- FIXED: Added 'id' to the JSON output ---
      // Note: Typically, you don't send the 'id' when creating a new record,
      // but it's good practice for the toJson method to be complete.
      'id': id,
      'carTransportId': carTransportId,
      'rating': rating,
      'comment': comment,
    };
  }
}

class Site {
  final int? id;
  final String status;
  final String? notes;
  final double latitude;
  final double longitude;
  final int flockId;
  Site({
    this.id,
    required this.status,
    this.notes,
    required this.latitude,
    required this.longitude,
    required this.flockId,
  });
  factory Site.fromJson(Map json) {
    return Site(
      id: json['id'],
      status: json['status'],
      notes: json['notes'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      flockId: json['flock_id'],
    );
  }
  Map toJson() {
    return {
      'id': id,
      'status': status,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'flock_id': flockId,
    };
  }
}
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
  
  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      status: json['status'],
      notes: json['notes'],
      latitude: json['latitude'] is int ? (json['latitude'] as int).toDouble() : json['latitude'],
      longitude: json['longitude'] is int ? (json['longitude'] as int).toDouble() : json['longitude'],
      flockId: json['flock_id'],
    );
  }
  
  Map<String, dynamic> toJson() {
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


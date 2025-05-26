class Visit {
  final int? id;
  final DateTime date;
  final String? notes;
  final int siteId;
  Visit({
    this.id,
    required this.date,
    this.notes,
    required this.siteId,
  });
  factory Visit.fromJson(Map json) {
    return Visit(
      id: json['id'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      siteId: json['site_id'],
    );
  }
  Map toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T').first,
      'notes': notes,
      'site_id': siteId,
    };
  }
}

class ScanHistory {
  final int? id;
  final String content;
  final String type;
  final DateTime scannedAt;

  ScanHistory({
    this.id,
    required this.content,
    required this.type,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  factory ScanHistory.fromMap(Map<String, dynamic> map) {
    return ScanHistory(
      id: map['id'] as int?,
      content: map['content'] as String,
      type: map['type'] as String,
      scannedAt: DateTime.parse(map['scanned_at'] as String),
    );
  }

  ScanHistory copyWith({
    int? id,
    String? content,
    String? type,
    DateTime? scannedAt,
  }) {
    return ScanHistory(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  /// Detect the type of QR content
  static String detectType(String content) {
    final lower = content.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return 'URL';
    } else if (lower.startsWith('wifi:')) {
      return 'WIFI';
    } else if (lower.startsWith('mailto:')) {
      return 'EMAIL';
    } else if (lower.startsWith('tel:')) {
      return 'PHONE';
    } else if (lower.startsWith('sms:') || lower.startsWith('smsto:')) {
      return 'SMS';
    } else if (lower.startsWith('begin:vcard') || lower.startsWith('mecard:')) {
      return 'CONTACT';
    } else if (lower.startsWith('geo:')) {
      return 'LOCATION';
    } else {
      return 'TEXT';
    }
  }

  @override
  String toString() {
    return 'ScanHistory{id: $id, content: $content, type: $type, scannedAt: $scannedAt}';
  }
}
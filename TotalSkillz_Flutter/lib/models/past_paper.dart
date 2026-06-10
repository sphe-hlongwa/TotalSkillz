class PastPaper {
  final String id;
  final String title;
  final String year;
  final String province;
  final String type; // 'Paper 1', 'Paper 2', 'Memorial'
  final String? url;

  const PastPaper({
    required this.id,
    required this.title,
    required this.year,
    required this.province,
    required this.type,
    this.url,
  });

  factory PastPaper.fromMap(Map<String, dynamic> map, String id) {
    return PastPaper(
      id: id,
      title: map['title'] ?? '',
      year: map['year'] ?? '',
      province: map['province'] ?? '',
      type: map['type'] ?? '',
      url: map['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'province': province,
      'type': type,
      'url': url,
    };
  }
}

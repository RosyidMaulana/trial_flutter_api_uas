class Finance {
  final int? id;
  final String title;
  final String type;
  final String date;
  final int amount;
  final String description;
  final String? photoUrl;

  Finance({
    this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.amount,
    required this.description,
    this.photoUrl,
  });

  factory Finance.fromJson(Map<String, dynamic> json) {
    return Finance(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      date: json['date'],
      amount: int.parse(json['amount'].toString()),
      description: json['description'],
      photoUrl: json['photo'],
    );
  }
}

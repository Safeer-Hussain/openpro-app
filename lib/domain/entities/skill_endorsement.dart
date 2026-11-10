class Endorser {
  final String id;
  final String name;
  final String title;
  final String avatarUrl;

  const Endorser({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarUrl,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'title': title,
    'avatar_url': avatarUrl,
  };

  factory Endorser.fromMap(Map<String, dynamic> map) => Endorser(
    id: map['id'] as String? ?? '',
    name: map['name'] as String? ?? '',
    title: map['title'] as String? ?? '',
    avatarUrl: map['avatar_url'] as String? ?? '',
  );
}

class SkillEndorsement {
  final String skillName;
  final int count;
  final bool isEndorsedByMe;
  final List<Endorser> topEndorsers;

  const SkillEndorsement({
    required this.skillName,
    required this.count,
    required this.isEndorsedByMe,
    required this.topEndorsers,
  });

  SkillEndorsement copyWith({
    String? skillName,
    int? count,
    bool? isEndorsedByMe,
    List<Endorser>? topEndorsers,
  }) {
    return SkillEndorsement(
      skillName: skillName ?? this.skillName,
      count: count ?? this.count,
      isEndorsedByMe: isEndorsedByMe ?? this.isEndorsedByMe,
      topEndorsers: topEndorsers ?? this.topEndorsers,
    );
  }
}

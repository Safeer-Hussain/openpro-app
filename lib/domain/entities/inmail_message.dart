class InmailMessage {
  final String id;
  final String userId;
  final String senderName;
  final String senderRole;
  final String senderCompany;
  final String senderAvatar;
  final String category; // 'recruiter' | 'general'
  final String subject;
  final String body;
  final String? opportunityTitle;
  final String? opportunitySalary;
  final String status; // 'unread' | 'read' | 'replied'
  final String? replyContent;
  final String sentAt;
  final String? repliedAt;

  const InmailMessage({
    required this.id,
    required this.userId,
    required this.senderName,
    required this.senderRole,
    required this.senderCompany,
    required this.senderAvatar,
    required this.category,
    required this.subject,
    required this.body,
    this.opportunityTitle,
    this.opportunitySalary,
    required this.status,
    this.replyContent,
    required this.sentAt,
    this.repliedAt,
  });

  bool get isRecruiter => category == 'recruiter';
  bool get isGeneral => category == 'general';
  bool get isUnread => status == 'unread';
  bool get isRead => status == 'read';
  bool get isReplied => status == 'replied';

  InmailMessage copyWith({
    String? id,
    String? userId,
    String? senderName,
    String? senderRole,
    String? senderCompany,
    String? senderAvatar,
    String? category,
    String? subject,
    String? body,
    String? opportunityTitle,
    String? opportunitySalary,
    String? status,
    String? replyContent,
    String? sentAt,
    String? repliedAt,
  }) {
    return InmailMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      senderCompany: senderCompany ?? this.senderCompany,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      opportunityTitle: opportunityTitle ?? this.opportunityTitle,
      opportunitySalary: opportunitySalary ?? this.opportunitySalary,
      status: status ?? this.status,
      replyContent: replyContent ?? this.replyContent,
      sentAt: sentAt ?? this.sentAt,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'sender_company': senderCompany,
      'sender_avatar': senderAvatar,
      'category': category,
      'subject': subject,
      'body': body,
      'opportunity_title': opportunityTitle,
      'opportunity_salary': opportunitySalary,
      'status': status,
      'reply_content': replyContent,
      'sent_at': sentAt,
      'replied_at': repliedAt,
    };
  }

  factory InmailMessage.fromMap(Map<String, dynamic> map) {
    return InmailMessage(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      senderName: map['sender_name'] as String? ?? '',
      senderRole: map['sender_role'] as String? ?? '',
      senderCompany: map['sender_company'] as String? ?? '',
      senderAvatar: map['sender_avatar'] as String? ?? '',
      category: map['category'] as String? ?? 'recruiter',
      subject: map['subject'] as String? ?? '',
      body: map['body'] as String? ?? '',
      opportunityTitle: map['opportunity_title'] as String?,
      opportunitySalary: map['opportunity_salary'] as String?,
      status: map['status'] as String? ?? 'unread',
      replyContent: map['reply_content'] as String?,
      sentAt: map['sent_at'] as String? ?? '',
      repliedAt: map['replied_at'] as String?,
    );
  }
}

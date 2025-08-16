import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmodel {
  String? id;
  String? title;
  String? descriptions;
  String? ratings;
  int? pages;
  String? language;
  String? audioLength;
  String? auther;
  String? aboutAuthor;
  String? bookUrl;
  String? imageUrl;
  String? coverUrl;
  String? audioUrl;
  String? category;
  int? price;
  int? numofRatings;
  String visibility; // 'public' or 'private'
  String? uploaderId; // To track who uploaded the book

  Bookmodel({
    this.id,
    this.title,
    this.descriptions,
    this.ratings,
    this.pages,
    this.language,
    this.audioLength,
    this.auther,
    this.aboutAuthor,
    this.bookUrl,
    this.imageUrl,
    this.coverUrl,
    this.audioUrl,
    this.category,
    this.price,
    this.numofRatings,
    required this.visibility, // Made required
    this.uploaderId,
  });

  Bookmodel.fromJson(Map<String, dynamic> json) : visibility = json["visibility"] ?? 'public' {
    id = json["id"];
    title = json["title"];
    descriptions = json["descriptions"];
    ratings = json["ratings"];
    pages = json["pages"];
    language = json["language"];
    audioLength = json["audioLength"];
    auther = json["auther"];
    aboutAuthor = json["aboutAuthor"];
    bookUrl = json["bookUrl"];
    imageUrl = json["imageUrl"];
    coverUrl = json["coverUrl"];
    audioUrl = json["audioUrl"];
    category = json["category"];
    price = json["price"];
    numofRatings = json["numofRatings"];
    uploaderId = json["uploaderId"];
  }

  get bookId => id;

  static List<Bookmodel> fromList(List<Map<String, dynamic>> list) {
    return list.map(Bookmodel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["title"] = title;
    _data["descriptions"] = descriptions;
    _data["ratings"] = ratings;
    _data["pages"] = pages;
    _data["language"] = language;
    _data["audioLength"] = audioLength;
    _data["auther"] = auther;
    _data["aboutAuthor"] = aboutAuthor;
    _data["bookUrl"] = bookUrl;
    _data["imageUrl"] = imageUrl;
    _data["coverUrl"] = coverUrl;
    _data["audioUrl"] = audioUrl;
    _data["category"] = category;
    _data["price"] = price;
    _data["numofRatings"] = numofRatings;
    _data["visibility"] = visibility; // Added visibility
    _data["uploaderId"] = uploaderId; // Added uploaderId
    return _data;
  }
}
// thought_post.dart
class ThoughtPost {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String content;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;

  ThoughtPost(this.likedBy, {
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.content,
    required this.timestamp,
    required this.likes,
    // Removed duplicate initialization of likedBy
  });

  factory ThoughtPost.fromJson(Map<String, dynamic> json) => ThoughtPost(
    List<String>.from(json['likedBy'] ?? []), // Pass likedBy as the first positional argument
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    userPhoto: json['userPhoto'],
    content: json['content'],
    timestamp: (json['timestamp'] as Timestamp).toDate(),
    likes: json['likes'] ?? 0,
    // Removed duplicate initialization of likedBy
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userPhoto': userPhoto,
    'content': content,
    'timestamp': timestamp,
    'likes': likes,
    'likedBy': likedBy,
  };
}

// book_request.dart
class BookRequest {
  final String id;
  final String userId;
  final String userName;
  final String bookTitle;
  final DateTime timestamp;
  final String status;

  BookRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookTitle,
    required this.timestamp,
    required this.status,
  });

  factory BookRequest.fromJson(Map<String, dynamic> json) => BookRequest(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    bookTitle: json['bookTitle'],
    timestamp: (json['timestamp'] as Timestamp).toDate(),
    status: json['status'] ?? 'Pending',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'bookTitle': bookTitle,
    'timestamp': timestamp,
    'status': status,
  };
}
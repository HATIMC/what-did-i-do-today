import 'dart:convert';

class ActivityMedia {
  final String mediaId;
  final String mediaPath;

  ActivityMedia({required this.mediaId, required this.mediaPath});

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {'mediaId': mediaId, 'mediaPath': mediaPath};
  }

  String toRawJson() => json.encode(toJson());

  factory ActivityMedia.fromJson(Map<String, dynamic> json) {
    return ActivityMedia(
      mediaId: json['mediaId'] ?? '',
      mediaPath: json['mediaPath'] ?? '',
    );
  }

  factory ActivityMedia.fromRawJson(String str) =>
      ActivityMedia.fromJson(json.decode(str));

  ActivityMedia copyWith({String? mediaId, String? mediaPath}) {
    return ActivityMedia(
      mediaId: mediaId ?? this.mediaId,
      mediaPath: mediaPath ?? this.mediaPath,
    );
  }
}

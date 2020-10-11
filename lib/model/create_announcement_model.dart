import 'dart:convert';
class AnnouncementListResponse {
    AnnouncementListResponse({
        this.announcements,
    });

    final List<AnnouncementModel> announcements;

    factory AnnouncementListResponse.fromRawJson(String str) => AnnouncementListResponse.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AnnouncementListResponse.fromJson(Map<String, dynamic> json) => AnnouncementListResponse(
        announcements: json["announcements"] == null ? null : List<AnnouncementModel>.from(json["announcements"].map((x) => AnnouncementModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "announcements": announcements == null ? null : List<dynamic>.from(announcements.map((x) => x.toJson())),
    };
}

class AnnouncementModel {
    AnnouncementModel({
        this.title,
        this.description,
        this.isForAll,
        this.batches,
        this.createdAt,
        this.owner
    });

    final String description;
    final String title;
    final bool isForAll;
    final List<String> batches;
    final DateTime createdAt;
    final String owner;

    factory AnnouncementModel.fromRawJson(String str) => AnnouncementModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AnnouncementModel.fromJson(Map<String, dynamic> json) => AnnouncementModel(
        description: json["description"] == null ? null : json["description"],
        title: json["title"] == null ? null : json["title"],
        isForAll: json["isForAll"] == null ? null : json["isForAll"],
        batches: json["batches"] == null ? null : List<String>.from(json["batches"].map((x) => x)),
        owner: json["owner"] == null ? null : json["owner"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "isForAll": isForAll == null ? null : isForAll,
        "batches": batches == null ? null : List<dynamic>.from(batches.map((x) => x)),
        "owner": owner == null ? null : owner,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
    };
}
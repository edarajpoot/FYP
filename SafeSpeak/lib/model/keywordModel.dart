class KeywordModel {
  final String? keywordID;
  final String userID;
  final String voiceText;

  KeywordModel({
    this.keywordID,
    required this.userID,
    required this.voiceText,
  });

  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "voiceText": voiceText,
    };
  }

  factory KeywordModel.fromMap(String id, Map<String, dynamic> map) {
  return KeywordModel(
    keywordID: id,
    userID: map["userID"] ?? "",  
    voiceText: map["voiceText"] ?? "",  
  );
}



}

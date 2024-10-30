class UserDetails {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  UserDetails({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }
}

class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String street;
  final String city;
  final String zipcode;
  final String companyName;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.street,
    required this.city,
    required this.zipcode,
    required this.companyName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String,
      street: (json['address'] as Map<String, dynamic>)['street'] as String,
      city: (json['address'] as Map<String, dynamic>)['city'] as String,
      zipcode: (json['address'] as Map<String, dynamic>)['zipcode'] as String,
      companyName: (json['company'] as Map<String, dynamic>)['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'website': website,
      'address': {
        'street': street,
        'city': city,
        'zipcode': zipcode,
      },
      'company': {
        'name': companyName,
      },
    };
  }

  // Tạo bản copy với các field được thay đổi
  User copyWith({
    String? name,
    String? username,
    String? email,
    String? phone,
    String? website,
    String? street,
    String? city,
    String? zipcode,
    String? companyName,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      street: street ?? this.street,
      city: city ?? this.city,
      zipcode: zipcode ?? this.zipcode,
      companyName: companyName ?? this.companyName,
    );
  }
}

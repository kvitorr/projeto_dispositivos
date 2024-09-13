
class Users {
  final int? usrId;
  final String usrName;
  final String usrPassword;
  final String? email;

  Users({
    this.usrId,
    required this.usrName,
    required this.usrPassword,
    required this.email,
  });

  // Construtor sem usrId e email
  Users.withoutIdAndEmail({
    required this.usrName,
    required this.usrPassword,
  }) : usrId = null, email = null;


  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        usrName: json["usrName"],
        usrPassword: json["usrPassword"],
        email: json["email"],
      );

  get usrEmail => this.email;

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "usrName": usrName,
        "usrPassword": usrPassword,
        "email": email,
      };
}
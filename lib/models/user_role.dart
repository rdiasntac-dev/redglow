enum UserRole { client, provider }

extension UserRoleLabel on UserRole {
  String get title => switch (this) {
        UserRole.client => 'Cliente',
        UserRole.provider => 'Prestadora',
      };

  String get description => switch (this) {
        UserRole.client => 'Quero contratar serviços',
        UserRole.provider => 'Quero oferecer serviços',
      };
}

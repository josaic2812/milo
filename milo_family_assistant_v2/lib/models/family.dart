class FamilyMember {
  final String id;
  final String name;
  final String role;
  final String? email;

  const FamilyMember({required this.id, required this.name, this.role = 'member', this.email});
}

class Family {
  final String id;
  final String name;
  final List<FamilyMember> members;

  const Family({required this.id, required this.name, this.members = const []});
}

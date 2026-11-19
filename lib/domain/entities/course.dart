import 'package:equatable/equatable.dart';

/// Curso académico indexable en O(1) por [id].
class Course extends Equatable {
  final String id;
  final String name;
  final String professor;

  const Course({required this.id, required this.name, this.professor = ''});

  // {P} id.trim().isNotEmpty ∧ name.trim().isNotEmpty
  // C   Course.create(id, name, professor)
  // {Q} result ∈ Course ∧ result.id == id.trim().toUpperCase() ∧ result.name.isNotEmpty
  factory Course.create({
    required String id,
    required String name,
    String professor = '',
  }) {
    final normalizedId = id.trim().toUpperCase();
    final normalizedName = name.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('id de curso no puede estar vacío');
    }
    if (normalizedName.isEmpty) {
      throw ArgumentError('name de curso no puede estar vacío');
    }
    return Course(
      id: normalizedId,
      name: normalizedName,
      professor: professor.trim(),
    );
  }

  @override
  List<Object?> get props => [id, name, professor];
}

import 'package:flutter/material.dart';
import 'package:myapp/components/student_item.dart';
import 'package:myapp/models/student_model.dart';

class ListStudents extends StatelessWidget {
  const ListStudents({
    super.key,
    required this.students,
    required this.onEditStudent,
  });

  final List<Student> students;
  final Function onEditStudent;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return StudentItem(student: student, onEditStudent: onEditStudent);
      },
    );
  }
}

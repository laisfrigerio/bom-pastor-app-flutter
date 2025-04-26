import 'package:flutter/material.dart';
import 'package:bom_pastor_app/components/students/student_item.dart';
import 'package:bom_pastor_app/models/student_model.dart';

class ListStudents extends StatelessWidget {
  const ListStudents({
    super.key,
    required this.students,
    required this.onEditStudent,
    required this.onEditStudentScore,
    required this.onDeleteStudent,
  });

  final List<Student> students;
  final Function onEditStudent;
  final Function onEditStudentScore;
  final Function onDeleteStudent;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final isLast = index == (students.length - 1);
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 80.0 : 0.0),
          child: StudentItem(
            student: student,
            onEditStudent: onEditStudent,
            onDeletetStudent: onDeleteStudent,
            onEditStudentScore: onEditStudentScore,
          ),
        );
      },
    );
  }
}

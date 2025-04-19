import 'package:flutter/material.dart';
import 'package:myapp/models/student_model.dart';
import 'package:myapp/config/app_colors.dart';

class StudentItem extends StatelessWidget {
  const StudentItem({
    super.key,
    required this.student,
    required this.onEditStudent,
  });

  final Student student;
  final Function onEditStudent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(
            20.0,
          ), // Define o raio do arredondamento (ajuste conforme necessário)
        ),
        child: ListTile(
          leading: const Icon(Icons.person), // Ícone de usuário
          title: Text(
            student.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Pontuação: ${student.score}'),
          trailing: IconButton(
            onPressed: () {
              onEditStudent(student);
            },
            icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}

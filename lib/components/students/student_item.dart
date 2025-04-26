import 'package:flutter/material.dart';
import 'package:bom_pastor_app/models/student_model.dart';
import 'package:bom_pastor_app/config/app_colors.dart';

class StudentItem extends StatelessWidget {
  const StudentItem({
    super.key,
    required this.student,
    required this.onEditStudent,
    required this.onEditStudentScore,
    required this.onDeletetStudent,
  });

  final Student student;
  final Function onEditStudent;
  final Function onEditStudentScore;
  final Function onDeletetStudent;

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
        child: InkWell(
          key: const Key('student_item_tap'),
          onTap: () {
            onEditStudentScore(student);
          },
          child: ListTile(
            leading: const Icon(Icons.person), // Ícone de usuário
            title: Text(
              student.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Pontuação: ${student.score}'),
            trailing: PopupMenuButton(
              onSelected: (String result) {
                switch (result) {
                  case 'edit':
                    onEditStudent(student);
                    break;
                  case 'delete':
                    onDeletetStudent(student);
                    break;
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        spacing: 8.0,
                        children: [Icon(Icons.edit, size: 15), Text('Editar')],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        spacing: 8.0,
                        children: [
                          Icon(Icons.delete, size: 15),
                          Text('Deletar'),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        ),
      ),
    );
  }
}

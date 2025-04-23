import 'package:flutter/material.dart';
import 'package:bom_pastor_app/models/classroom_model.dart';
import 'package:bom_pastor_app/config/app_colors.dart';

class ClassRoomItem extends StatelessWidget {
  const ClassRoomItem({
    super.key,
    required this.classroom,
    required this.onListStudents,
    required this.onEditClassRoom,
  });

  final ClassRoom classroom;
  final Function onListStudents;
  final Function onEditClassRoom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: InkWell(
          key: const Key('classroom_item_tap'),
          onTap: () {
            onListStudents(classroom.name, classroom.spreadSheetName);
          },
          child: ListTile(
            leading: const Icon(Icons.school),
            title: Text(
              classroom.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: PopupMenuButton(
              onSelected: (String result) {
                switch (result) {
                  case 'edit':
                    onEditClassRoom(classroom);
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
                  ],
            ),
          ),
        ),
      ),
    );
  }
}

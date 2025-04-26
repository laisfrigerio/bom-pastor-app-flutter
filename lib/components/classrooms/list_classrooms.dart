import 'package:bom_pastor_app/models/classroom_model.dart';
import 'package:flutter/material.dart';
import 'package:bom_pastor_app/components/classrooms/classroom_item.dart';

class ListClassRooms extends StatelessWidget {
  const ListClassRooms({
    super.key,
    required this.classrooms,
    required this.onListStudents,
    required this.onEditClassRoom,
  });

  final List<ClassRoom> classrooms;
  final Function onListStudents;
  final Function onEditClassRoom;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: classrooms.length,
      itemBuilder: (context, index) {
        final classroom = classrooms[index];
        final isLast = index == (classrooms.length - 1);
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 180.0 : 0.0),
          child: ClassRoomItem(
            classroom: classroom,
            onListStudents: onListStudents,
            onEditClassRoom: onEditClassRoom,
          ),
        );
      },
    );
  }
}

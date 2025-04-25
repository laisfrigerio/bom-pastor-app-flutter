import 'package:bom_pastor_app/adapters/classroom_adapter.dart';
import 'package:bom_pastor_app/components/classrooms/list_classrooms.dart';
import 'package:bom_pastor_app/config/app_colors.dart';
import 'package:bom_pastor_app/config/sheet_config.dart';
import 'package:bom_pastor_app/models/classroom_model.dart';
import 'package:bom_pastor_app/screens/classrooms/edit_classroom_screen.dart';
import 'package:bom_pastor_app/screens/students/list_students_screen.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';
import 'package:flutter/material.dart';

class ListClassRoomScreen extends StatefulWidget {
  const ListClassRoomScreen({super.key, required this.title});

  final String title;

  @override
  State<ListClassRoomScreen> createState() => _ListClassRoomScreenState();
}

class _ListClassRoomScreenState extends State<ListClassRoomScreen> {
  final GoogleSheetApi googleSheetApi = GoogleSheetApi();

  List<ClassRoom> _classrooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getClassRoomsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _renderAppBar(), body: _renderClassRoomsList());
  }

  Future<void> _getClassRoomsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<List<dynamic>> fetchedRows = await googleSheetApi
          .readGoogleSheetData(
            SheetConfig.spreadSheetId,
            SheetConfig.sheetListClassRoomsName,
          );

      List<ClassRoom> fetchedClassRooms = listFromSheet(fetchedRows);

      if (fetchedClassRooms.isNotEmpty) {
        setState(() {
          _classrooms = fetchedClassRooms;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _navigateToListStudentsScreen(
    String classRoomName,
    String classRoomSpreadSheetName,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ListStudentsScreen(
              title: classRoomName,
              spreadSheetName: classRoomSpreadSheetName,
            ),
      ),
    );
  }

  Future<void> _navigateToEditClassRoomScreen(ClassRoom classRoom) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditClassRoomScreen(classRoom: classRoom),
      ),
    );

    if (result == true) {
      _getClassRoomsData();
    }
  }

  Widget _renderClassRoomsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_classrooms.isEmpty) {
      return const Center(child: Text('Nenhuma turma encontrada'));
    }

    return Column(
      children: [
        Expanded(
          child: ListClassRooms(
            classrooms: _classrooms,
            onListStudents: _navigateToListStudentsScreen,
            onEditClassRoom: _navigateToEditClassRoomScreen,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _renderAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      title: Text(widget.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _getClassRoomsData();
          },
        ),
      ],
    );
  }
}

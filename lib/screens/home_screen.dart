import 'package:flutter/material.dart';

import 'package:bom_pastor_app/adapters/student_adapter.dart';
import 'package:bom_pastor_app/components/list_students.dart';
import 'package:bom_pastor_app/config/app_colors.dart';
import 'package:bom_pastor_app/config/sheet_config.dart';
import 'package:bom_pastor_app/models/student_model.dart';
import 'package:bom_pastor_app/screens/edit_student_screen.dart';
import 'package:bom_pastor_app/screens/new_student_screen.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getStudentsData();
  }

  Future<void> _getStudentsData() async {
    try {
      List<List<dynamic>> fetchedRows = await readGoogleSheetData(
        SheetConfig.spreadSheetId,
        SheetConfig.sheetListStudentsName,
      );

      List<Student> fetchedStudents = listFromSheet(fetchedRows);

      if (fetchedStudents.isNotEmpty) {
        setState(() {
          _students = fetchedStudents;
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

  Future<void> _navigateToAddStudent() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NewStudentScreen()));

    print("lais");
    if (result == true) {
      _getStudentsData();
    }
  }

  Future<void> _navigateToEditStudent(Student student) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => EditStudentScreen(
              studentScore: student.score,
              studentName: student.name,
              rowNumber: student.rowId + 1,
            ),
      ),
    );

    if (result == true) {
      _getStudentsData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListStudents(
                      students: _students,
                      onEditStudent: _navigateToEditStudent,
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          _navigateToAddStudent();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

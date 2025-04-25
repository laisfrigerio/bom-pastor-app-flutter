import 'package:flutter/material.dart';

import 'package:bom_pastor_app/adapters/student_adapter.dart';
import 'package:bom_pastor_app/components/students/list_students.dart';
import 'package:bom_pastor_app/config/app_colors.dart';
import 'package:bom_pastor_app/config/sheet_config.dart';
import 'package:bom_pastor_app/models/student_model.dart';
import 'package:bom_pastor_app/screens/students/edit_student_score_screen.dart';
import 'package:bom_pastor_app/screens/students/edit_student_screen.dart';
import 'package:bom_pastor_app/screens/students/new_student_screen.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class ListStudentsScreen extends StatefulWidget {
  const ListStudentsScreen({
    super.key,
    required this.title,
    required this.spreadSheetName,
    this.googleSheetApi,
  });

  final String title;
  final String spreadSheetName;
  final IGoogleSheetApi? googleSheetApi;

  @override
  State<ListStudentsScreen> createState() => _ListStudentsScreenState();
}

class _ListStudentsScreenState extends State<ListStudentsScreen> {
  late IGoogleSheetApi _googleSheetApi;

  List<Student> _students = [];
  bool _isLoading = true;

  @visibleForTesting
  set googleSheetApi(IGoogleSheetApi value) {
    _googleSheetApi = value;
  }

  @override
  void initState() {
    super.initState();
    _googleSheetApi = widget.googleSheetApi ?? GoogleSheetApi();
    _getStudentsData();
  }

  Future<void> _getStudentsData() async {
    setState(() {
      _isLoading = true;
      _students = [];
    });

    try {
      List<List<dynamic>> fetchedRows = await _googleSheetApi
          .readGoogleSheetData(
            SheetConfig.spreadSheetId,
            widget.spreadSheetName,
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

  Future<void> _navigateToAddStudent(String spreadSheetName) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => NewStudentScreen(spreadSheetName: spreadSheetName),
      ),
    );

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
              spreadSheetName: widget.spreadSheetName,
            ),
      ),
    );

    if (result == true) {
      _getStudentsData();
    }
  }

  Future<void> _navigateToEditStudentScore(Student student) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => EditStudentScoreScreen(
              student: student,
              spreadSheetName: widget.spreadSheetName,
            ),
      ),
    );

    if (result == true) {
      _getStudentsData();
    }
  }

  Future<void> _onDeleteStudent(Student student) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _googleSheetApi.deleteGoogleSheetRow(
        student.rowId,
        SheetConfig.spreadSheetId,
        widget.spreadSheetName,
      );
      _getStudentsData();
    } catch (e) {
      _showSnackBarMessage(
        message: 'Erro ao remover aluno: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBarMessage({
    required String message,
    Color backgroundColor = AppColors.grey700,
  }) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: backgroundColor, content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getStudentsData();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListStudents(
                      students: _students,
                      onDeleteStudent: _onDeleteStudent,
                      onEditStudent: _navigateToEditStudent,
                      onEditStudentScore: _navigateToEditStudentScore,
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          _navigateToAddStudent(widget.spreadSheetName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

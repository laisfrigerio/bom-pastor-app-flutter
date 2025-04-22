import 'package:flutter/material.dart';

import 'package:bom_pastor_app/models/student_model.dart';
import 'package:bom_pastor_app/config/app_colors.dart';
import 'package:bom_pastor_app/config/sheet_config.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class EditStudentScoreScreen extends StatefulWidget {
  const EditStudentScoreScreen({
    super.key,
    required this.student,
    required this.spreadSheetName,
  });

  final String spreadSheetName;
  final Student student;

  @override
  State<EditStudentScoreScreen> createState() => _EditStudentScoreScreenState();
}

class _EditStudentScoreScreenState extends State<EditStudentScoreScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentScoreController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.student.name;
    _currentScoreController.text = widget.student.score.toString();
  }

  Future<void> _updateStudent(String newName, int newScore) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await updateGoogleSheetRow(
        [newName, newScore],
        widget.student.rowId + 1,
        SheetConfig.spreadSheetId,
        widget.spreadSheetName,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Indicate success
      }
    } catch (e) {
      _showSnackBarMessage(
        message: 'Erro ao atualizar aluno: $e',
        backgroundColor: Colors.red,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void onDecreaseScore() async {
    if (_isLoading) {
      return null;
    }

    if (_scoreController.text.isNotEmpty) {
      try {
        int scoreFromInput = int.parse(_scoreController.text);
        int newScore = widget.student.score - scoreFromInput;

        await _updateStudent(_nameController.text, newScore);
      } catch (e) {
        _showSnackBarMessage(
          message: 'Ocorreu um erro ao diminuir score $e',
          backgroundColor: Colors.red,
        );
      }
    } else {
      _showSnackBarMessage(
        message: 'Número da pontuação obrigatório',
        backgroundColor: Colors.red,
      );
    }
  }

  void onIncreaseScore() async {
    if (_isLoading) {
      return null;
    }

    if (_scoreController.text.isNotEmpty) {
      try {
        int scoreFromInput = int.parse(_scoreController.text);
        int newScore = widget.student.score + scoreFromInput;

        await _updateStudent(_nameController.text, newScore);
      } catch (e) {
        _showSnackBarMessage(
          message: 'Ocorreu um erro ao aumentar score $e',
          backgroundColor: Colors.red,
        );
      }
    } else {
      _showSnackBarMessage(
        message: 'Número da pontuação obrigatório',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Editar Pontuação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nome do Aluno',
                  labelText: 'Nome',
                ),
                enabled: false,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _currentScoreController,
                decoration: const InputDecoration(
                  hintText: 'Pontuação do Aluno',
                  labelText: 'Pontuação atual',
                ),
                enabled: false,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _scoreController,
                decoration: const InputDecoration(
                  hintText: 'Nova pontuação',
                  labelText: 'Pontuação',
                ),
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 50),
              showScoreButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showScoreButtons() {
    if (_isLoading) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8.0,
            children: [
              scoreButton(onPressed: onDecreaseScore, icon: Icons.remove),
              scoreButton(onPressed: onIncreaseScore, icon: Icons.add),
            ],
          ), // Use SizedBox for consistent spacing,
        ],
      );
    }
  }

  Widget scoreButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return MaterialButton(
      color: AppColors.primaryColor,
      textColor: Colors.white,
      onPressed: onPressed,
      child: Icon(icon),
    );
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
}

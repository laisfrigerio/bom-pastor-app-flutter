import 'package:flutter/material.dart';

import 'package:bom_pastor_app/config/app_colors.dart';
import 'package:bom_pastor_app/config/sheet_config.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class NewStudentScreen extends StatefulWidget {
  const NewStudentScreen({super.key});

  @override
  State<NewStudentScreen> createState() => _NewStudentScreenState();
}

class _NewStudentScreenState extends State<NewStudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Adicionar Novo Aluno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Icon(
                Icons.person_add,
                size: 100,
                color: AppColors.primaryColor,
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Nome do Aluno'),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 50),
              // const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  MaterialButton(
                    color: AppColors.grey100,
                    textColor: AppColors.grey700,
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.of(context).pop();
                            },
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  MaterialButton(
                    color: AppColors.primaryColor,
                    textColor: Colors.white,
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              if (_nameController.text.isNotEmpty) {
                                _addStudent(_nameController.text);
                              } else {
                                _showSnackBarMessage(
                                  message:
                                      'O nome do aluno não pode ser vazio.',
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addStudent(String studentName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await addGoogleSheetData(
        [studentName, 0],
        SheetConfig.spreadSheetId,
        SheetConfig.sheetListStudentsName,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackBarMessage(
        message: 'Erro ao adicionar aluno: $e',
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
}

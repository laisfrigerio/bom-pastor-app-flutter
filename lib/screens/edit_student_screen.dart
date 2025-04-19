import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for numeric input
import 'package:myapp/config/app_colors.dart';
import 'package:myapp/config/sheet_config.dart';
import 'package:myapp/third_party/google_sheet.dart';

class EditStudentScreen extends StatefulWidget {
  const EditStudentScreen({
    super.key,
    required this.studentName,
    required this.studentScore,
    required this.rowNumber,
  });

  final String studentName;
  final int studentScore;
  final int rowNumber;

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.studentName;
    _scoreController.text = widget.studentScore.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Editar Aluno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Icon(
                Icons.person,
                size: 100,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Nome do Aluno'),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _scoreController,
                decoration: const InputDecoration(
                  hintText: 'Pontuação do Aluno',
                ),
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*$')),
                ],
              ),
              const SizedBox(height: 50),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  MaterialButton(
                    color: AppColors.grey100,
                    textColor: AppColors.grey700,
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(
                    height: 10,
                  ), // Use SizedBox for consistent spacing
                  MaterialButton(
                    color: AppColors.primaryColor,
                    textColor: Colors.white,
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              if (_nameController.text.isNotEmpty &&
                                  _scoreController.text.isNotEmpty) {
                                _updateStudent(
                                  _nameController.text,
                                  int.tryParse(_scoreController.text) ??
                                      widget
                                          .studentScore, // Handle potential parsing error
                                );
                              } else {
                                _showSnackBarMessage(
                                  message: 'Nome e pontuação são obrigatórios.',
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

  Future<void> _updateStudent(String newName, int newScore) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await updateGoogleSheetRow(
        [newName, newScore],
        widget.rowNumber,
        SheetConfig.spreadSheetId,
        SheetConfig.sheetListStudentsName,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Indicate success
      }
    } catch (e) {
      _showSnackBarMessage(
        message: 'Erro ao atualizar aluno: $e',
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

import 'package:flutter/material.dart';

import 'package:bom_pastor_app/config/app_colors.dart';
import 'package:bom_pastor_app/config/sheet_config.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class NewStudentScreen extends StatefulWidget {
  const NewStudentScreen({
    super.key,
    required this.spreadSheetName,
    this.googleSheetApi,
  });

  final String spreadSheetName;
  final IGoogleSheetApi? googleSheetApi;

  @override
  State<NewStudentScreen> createState() => _NewStudentScreenState();
}

class _NewStudentScreenState extends State<NewStudentScreen> {
  late IGoogleSheetApi _googleSheetApi;

  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;

  @visibleForTesting
  set googleSheetApi(IGoogleSheetApi value) {
    _googleSheetApi = value;
  }

  @override
  void initState() {
    super.initState();
    _googleSheetApi = widget.googleSheetApi ?? GoogleSheetApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Adicionar Novo Aluno'),
        leading: IconButton(
          key: const Key('back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                    onPressed: _handleSaveButtonClick,
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
      await _googleSheetApi.addGoogleSheetData(
        [studentName, 0],
        SheetConfig.spreadSheetId,
        widget.spreadSheetName,
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

  void _handleSaveButtonClick() {
    if (_isLoading) {
      return;
    }

    if (_nameController.text.isNotEmpty) {
      _addStudent(_nameController.text);
      return;
    }

    _showSnackBarMessage(
      message: 'Campo nome é obrigatório',
      backgroundColor: Colors.red,
    );
  }

  void _showSnackBarMessage({
    required String message,
    Color backgroundColor = AppColors.grey700,
  }) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: backgroundColor, content: Text(message)),
        );
      });
    }
  }
}

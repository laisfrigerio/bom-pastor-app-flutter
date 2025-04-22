import 'package:bom_pastor_app/models/classroom_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for numeric input
import 'package:bom_pastor_app/config/app_colors.dart';
import 'package:bom_pastor_app/config/sheet_config.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class EditClassRoomScreen extends StatefulWidget {
  const EditClassRoomScreen({super.key, required this.classRoom});

  final ClassRoom classRoom;

  @override
  State<EditClassRoomScreen> createState() => _EditClassRoomScreenState();
}

class _EditClassRoomScreenState extends State<EditClassRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.classRoom.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Editar Turma'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Icon(
                Icons.school,
                size: 100,
                color: AppColors.primaryColor,
              ),

              const SizedBox(height: 20),

              _renderTextField(
                fieldController: _nameController,
                fieldType: TextInputType.text,
                hintText: 'Nome da Turma',
                labelText: 'Nome',
                fieldRegex: r'^[a-zA-Z0-9\- ]+$',
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
                    onPressed: _handleEditClassRoom,
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

  void _handleEditClassRoom() {
    if (_isLoading) {
      return;
    }

    if (_nameController.text.isNotEmpty) {
      _updateClassRoom(
        _nameController.text,
        widget.classRoom.code,
        widget.classRoom.spreadSheetName,
        SheetConfig.sheetListClassRoomsName, // Handle potential parsing error
      );
    } else {
      _showSnackBarMessage(
        message: 'Nome e código da turma não podem estar vazios.',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _updateClassRoom(
    String newName,
    String newCode,
    String currentSpreadSheetName,
    String sheetNameToBeEdited,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await updateGoogleSheetRow(
        [newCode, newName, widget.classRoom.spreadSheetName],
        widget.classRoom.rowId + 1,
        SheetConfig.spreadSheetId,
        sheetNameToBeEdited,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackBarMessage(
        message: 'Erro ao atualizar turma: $e',
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

  Widget _renderTextField({
    required TextEditingController fieldController,
    required String hintText,
    required String labelText,
    required String fieldRegex,
    required TextInputType fieldType,
  }) {
    return TextField(
      controller: fieldController,
      decoration: InputDecoration(hintText: hintText, labelText: labelText),
      enabled: !_isLoading,
      keyboardType: fieldType,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(fieldRegex)),
      ],
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

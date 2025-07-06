import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_comandas_app/modelos/item_comanda.dart';
import 'package:flutter_comandas_app/utilitarios/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AddItemForm extends StatefulWidget {
  const AddItemForm({super.key});

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        final File tempImage = File(pickedFile.path);
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(pickedFile.path);
        final newPath = p.join(appDir.path, fileName);

        if (!await appDir.exists()) {
          await appDir.create(recursive: true);
        }

        final File permanentImage = await tempImage.copy(newPath);

        setState(() {
          _imagePath = permanentImage.path;
        });
      } else {
        if (mounted) {
          showSnackBarMessage(context, 'Nenhuma imagem selecionada.');
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Erro ao selecionar imagem: $e',
          isError: true,
        );
      }
      print('Erro ao selecionar imagem: $e');
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final String name = _nomeController.text.trim();
      final int quantity = int.parse(_quantidadeController.text);
      final double price = double.parse(
        _precoController.text.replaceAll(',', '.'),
      );

      final newItem = ItemComanda(
        nome: name,
        quantidade: quantity,
        preco: price,
        caminhoFoto: _imagePath,
      );

      Navigator.of(context).pop(newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Novo Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(
                      File(_imagePath!),
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text('Tirar Foto'),
                          onTap: () {
                            Navigator.of(context).pop();
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.photo_library,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text('Escolher da Galeria'),
                          onTap: () {
                            Navigator.of(context).pop();
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.image),
                label: const Text('Adicionar Foto do Item'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Item',
                  hintText: 'Ex: Pizza, Refrigerante',
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o nome do item.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _quantidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  hintText: 'Ex: 1, 2',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade.';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Quantidade inválida. Insira um número inteiro positivo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _precoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Preço Unitário',
                  prefixText: 'R\$ ',
                  hintText: 'Ex: 15,99',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço.';
                  }
                  final cleanedValue = value.replaceAll(',', '.');
                  if (double.tryParse(cleanedValue) == null ||
                      double.parse(cleanedValue) <= 0) {
                    return 'Preço inválido. Insira um valor positivo (ex: 15.99 ou 15,99).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveItem,
                icon: const Icon(Icons.check),
                label: const Text('Salvar Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

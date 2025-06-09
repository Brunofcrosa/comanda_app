import 'package:flutter/material.dart';
import 'package:flutter_comandas_app/servicos/database/banco_dados.dart';
import 'package:flutter_comandas_app/modelos/comanda.dart';
import 'package:flutter_comandas_app/utilitarios/utils.dart';

class NewComandaForm extends StatefulWidget {
  final VoidCallback onSave;

  const NewComandaForm({super.key, required this.onSave});

  @override
  State<NewComandaForm> createState() => _NewComandaFormState();
}

class _NewComandaFormState extends State<NewComandaForm> {
  final TextEditingController _nomeController = TextEditingController();
  final BancoDados _banco = BancoDados.instancia;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _saveComanda() async {
    if (_isLoading || !mounted) return;

    final String name = _nomeController.text.trim();

    if (name.isEmpty) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'O nome da comanda não pode ser vazio.',
          isError: true,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newComandaToSave = Comanda(nome: name, itens: []);
      await _banco.salvarComanda(newComandaToSave);

      if (!mounted) return;

      widget.onSave();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          showSnackBarMessage(context, 'Comanda salva com sucesso!');
        }
      });
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Erro ao salvar comanda: $e',
          isError: true,
        );
      }
      print('Erro ao salvar comanda: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Comanda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveComanda,
            tooltip: _isLoading ? 'Salvando...' : 'Salvar Comanda',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da Comanda',
                hintText: 'Ex: Mesa 1, Comanda do Bruno',
                prefixIcon: Icon(Icons.receipt_long),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira um nome para a comanda.';
                }
                return null;
              },
            ),
          ),
          const Spacer(),
          if (_isLoading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

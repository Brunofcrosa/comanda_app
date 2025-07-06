import 'package:flutter/material.dart';
import 'package:flutter_comandas_app/comandas/card_item_comanda.dart';
import 'package:flutter_comandas_app/servicos/database/banco_dados.dart';
import 'package:flutter_comandas_app/modelos/comanda.dart';
import 'package:flutter_comandas_app/modelos/item_comanda.dart';
import 'package:flutter_comandas_app/utilitarios/utils.dart';
import 'package:flutter_comandas_app/comandas/novo_item.dart';
import 'package:intl/intl.dart';
import 'package:flutter_comandas_app/main.dart';

class EditarComandaPage extends StatefulWidget {
  final Comanda comanda;
  final VoidCallback onSave;

  const EditarComandaPage({
    super.key,
    required this.comanda,
    required this.onSave,
  });

  @override
  State<EditarComandaPage> createState() => _EditarComandaPageState();
}

class _EditarComandaPageState extends State<EditarComandaPage> {
  late Comanda _editingComanda;
  final BancoDados _banco = BancoDados.instancia;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _editingComanda = widget.comanda.copyWith(
      itens: List.from(widget.comanda.itens),
    );
  }

  Future<void> _saveComandaChanges() async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_editingComanda.id == null) {
        if (mounted) {
          showSnackBarMessage(
            context,
            'Erro: ID da comanda não encontrado para atualização.',
            isError: true,
          );
        }
        return;
      }
      await _banco.atualizarComanda(_editingComanda);

      if (!mounted) return;

      widget.onSave();
      Navigator.of(context).pop();
      showSnackBarMessage(context, 'Comanda atualizada com sucesso!');
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Erro ao atualizar comanda: $e',
          isError: true,
        );
      }
      print('Erro ao atualizar comanda: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToAddItemForm() async {
    final ItemComanda? newItem = await Navigator.push<ItemComanda>(
      context,
      MaterialPageRoute(builder: (context) => const AddItemForm()),
    );

    if (newItem != null) {
      setState(() {
        _editingComanda.itens.add(newItem);
      });
      if (mounted) {
        showSnackBarMessage(
          context,
          'Item adicionado temporariamente. Precisa Salvar!!!',
        );
      }
    }
  }

  void _removeItem(int index) {
    setState(() {
      _editingComanda.itens.removeAt(index);
    });
    if (mounted) {
      showSnackBarMessage(
        context,
        'Item removido temporariamente. Precisa Salvar!!!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalFormatado = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(_editingComanda.total);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('Comanda: ${_editingComanda.nome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: _isLoading ? null : _saveComandaChanges,
            tooltip: _isLoading ? 'Salvando...' : 'Salvar Alterações',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total da Comanda: $totalFormatado',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: ComandasApp.primaryCustomColor,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _editingComanda.itens.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_dining,
                                size: constraints.maxWidth > 600 ? 100 : 80,
                                color: ComandasApp.tertiaryGreyColor
                                    .withOpacity(0.8),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Nenhum item adicionado ainda.\nClique em "Adicionar Item" para começar!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: constraints.maxWidth > 600
                                      ? 20
                                      : 18,
                                  color: ComandasApp.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _editingComanda.itens.length,
                        itemBuilder: (context, index) {
                          final item = _editingComanda.itens[index];
                          return ComandaItemCard(
                            item: item,
                            onRemove: () => _removeItem(index),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToAddItemForm,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Adicionar Item'),
                  ),
                ),
              ),
              if (_isLoading) const LinearProgressIndicator(),
            ],
          );
        },
      ),
    );
  }
}
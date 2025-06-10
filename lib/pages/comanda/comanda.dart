// lib/pages/comanda/comanda.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_comandas_app/servicos/database/banco_dados.dart';
import 'package:flutter_comandas_app/modelos/comanda.dart';
import 'package:flutter_comandas_app/utilitarios/utils.dart';
import 'package:flutter_comandas_app/comandas/novacomanda.dart';
import 'package:flutter_comandas_app/comandas/editarcomanda.dart';
import 'package:flutter_comandas_app/main.dart';

class ComandaListPage extends StatefulWidget {
  const ComandaListPage({super.key});

  @override
  State<ComandaListPage> createState() => _ComandaListPageState();
}

class _ComandaListPageState extends State<ComandaListPage> {
  final BancoDados _banco = BancoDados.instancia;
  List<Comanda> _comandas = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _carregarComandas();
  }

  Future<void> _carregarComandas() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final comandas = await _banco.listarComandas();
      if (mounted) {
        setState(() {
          _comandas = comandas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        showSnackBarMessage(
          context,
          'Erro ao carregar comandas: ${e.toString()}',
          isError: true,
        );
      }
      debugPrint('Erro ao carregar comandas: $e');
    }
  }

  void _abrirComanda(Comanda comanda) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditarComandaPage(comanda: comanda, onSave: _carregarComandas),
      ),
    );
    _carregarComandas();
  }

  Future<void> _confirmarRemocaoComanda(Comanda comanda) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja remover a comanda "${comanda.nome}"?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ComandasApp.errorColor,
              ),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _removerComanda(comanda.id!);
    }
  }

  Future<void> _removerComanda(int id) async {
    try {
      await _banco.removerComanda(id);
      await _carregarComandas();
      if (mounted) {
        showSnackBarMessage(context, 'Comanda removida com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Erro ao remover comanda: ${e.toString()}',
          isError: true,
        );
      }
      debugPrint('Erro ao remover comanda: $e');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 100,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhuma comanda encontrada.\nClique no botão "+" para adicionar uma nova comanda!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Ocorreu um erro ao carregar as comandas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregarComandas,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComandaItem(Comanda comanda, int index) {
    final dataFormatada = DateFormat(
      'dd/MM/yyyy HH:mm',
      'pt_BR',
    ).format(comanda.dataCriacao);
    final totalFormatado = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(comanda.total);
    final String comandaTitle = 'Comanda ${index + 1}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () => _abrirComanda(comanda),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;

              if (isSmallScreen) {
                return _buildSmallComandaItem(
                  comanda,
                  comandaTitle,
                  dataFormatada,
                  totalFormatado,
                );
              } else {
                return _buildLargeComandaItem(
                  comanda,
                  comandaTitle,
                  dataFormatada,
                  totalFormatado,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSmallComandaItem(
    Comanda comanda,
    String title,
    String data,
    String total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.receipt,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              total,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ComandasApp.primaryCustomColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          comanda.nome,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 4),
            Text(
              data,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.list_alt,
              size: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 4),
            Text(
              '${comanda.itens.length} itens',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete, color: ComandasApp.errorColor, size: 20),
              onPressed: () => _confirmarRemocaoComanda(comanda),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Remover Comanda',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeComandaItem(
    Comanda comanda,
    String title,
    String data,
    String total,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.receipt,
          size: 30,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                comanda.nome,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.list_alt,
                    size: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${comanda.itens.length} itens',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              total,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ComandasApp.primaryCustomColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 38,
              height: 38,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.delete,
                  color: ComandasApp.errorColor,
                  size: 24,
                ),
                onPressed: () => _confirmarRemocaoComanda(comanda),
                tooltip: 'Remover Comanda',
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Comandas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarComandas,
            tooltip: 'Recarregar Comandas',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? _buildErrorState()
          : _comandas.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _carregarComandas,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _comandas.length,
                itemBuilder: (context, index) {
                  return _buildComandaItem(_comandas[index], index);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewComandaForm(onSave: _carregarComandas),
            ),
          );
          _carregarComandas();
        },
        tooltip: 'Adicionar Nova Comanda',
        child: const Icon(Icons.add),
      ),
    );
  }
}

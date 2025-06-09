import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_comandas_app/modelos/comprovante.dart';
import 'package:flutter_comandas_app/modelos/comanda.dart';
import 'package:flutter_comandas_app/servicos/database/banco_dados.dart';
import 'package:flutter_comandas_app/utilitarios/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_comandas_app/main.dart';

class ComprovantesPage extends StatefulWidget {
  const ComprovantesPage({super.key});

  @override
  State<ComprovantesPage> createState() => _ComprovantesPageState();
}

class _ComprovantesPageState extends State<ComprovantesPage> {
  List<Comprovante> _comprovantes = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  final BancoDados _banco = BancoDados.instancia;

  @override
  void initState() {
    super.initState();
    _carregarComprovantes();
  }

  Future<void> _carregarComprovantes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final comprovantes = await _banco.listarComprovantes();
      setState(() {
        _comprovantes = comprovantes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Erro ao carregar comprovantes: $e',
          isError: true,
        );
      }
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar comprovantes: $e');
    }
  }

  Future<void> _tirarFotoOuEscolherGaleria(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        final File imagemTemporaria = File(pickedFile.path);
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(pickedFile.path);
        final caminhoPermanente = p.join(appDir.path, fileName);

        if (!await appDir.exists()) {
          await appDir.create(recursive: true);
        }

        final File novaImagem = await imagemTemporaria.copy(caminhoPermanente);
        _mostrarOpcoesComprovante(novaImagem.path);
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

  Future<void> _mostrarOpcoesComprovante(String caminhoArquivo) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Comprovante Capturado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(caminhoArquivo),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image,
                    size: 80,
                    color: Theme.of(context).colorScheme.error,
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _vincularComprovante(caminhoArquivo);
                },
                child: const Text('Vincular a uma Comanda'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final novoComprovante = Comprovante(
                    caminhoArquivo: caminhoArquivo,
                    dataCaptura: DateTime.now(),
                    descricao: 'Comprovante avulso',
                  );
                  await _banco.inserirComprovante(novoComprovante);
                  _carregarComprovantes();
                  if (mounted) {
                    showSnackBarMessage(
                      context,
                      'Comprovante salvo como avulso!',
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: const Text('Salvar como avulso'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _vincularComprovante(String caminhoArquivo) async {
    final comandas = await _banco.listarComandas();

    if (comandas.isEmpty) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Nenhuma comanda encontrada para vincular.',
          isError: true,
        );
      }
      return;
    }

    Comanda? comandaSelecionada = await showDialog<Comanda>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Vincular Comprovante à Comanda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: comandas.map((comanda) {
                return ListTile(
                  title: Text(
                    '${comanda.nome} - Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(comanda.total)}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(comanda);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (comandaSelecionada != null) {
      final novoComprovante = Comprovante(
        caminhoArquivo: caminhoArquivo,
        dataCaptura: DateTime.now(),
        idComandaVinculada: comandaSelecionada.id,
        descricao: 'Comprovante para ${comandaSelecionada.nome}',
      );

      try {
        await _banco.inserirComprovante(novoComprovante);
        _carregarComprovantes();
        if (mounted) {
          showSnackBarMessage(context, 'Comprovante vinculado com sucesso!');
        }
      } catch (e) {
        if (mounted) {
          showSnackBarMessage(
            context,
            'Erro ao vincular comprovante: $e',
            isError: true,
          );
        }
        print('Erro ao vincular comprovante: $e');
      }
    }
  }

  Future<void> _abrirImagemComprovante(Comprovante comprovante) async {
    String? comandaNome;
    if (comprovante.idComandaVinculada != null) {
      final comanda = await _banco.buscarComandaPorId(
        comprovante.idComandaVinculada!,
      );
      comandaNome = comanda?.nome;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(comprovante.descricao ?? 'Comprovante'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(
                  File(comprovante.caminhoArquivo),
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(comprovante.dataCaptura.toLocal())}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                if (comprovante.idComandaVinculada != null)
                  Text(
                    'Vinculado à Comanda: ${comandaNome ?? comprovante.idComandaVinculada}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fechar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final fileToRemove = File(comprovante.caminhoArquivo);
                  if (await fileToRemove.exists()) {
                    await fileToRemove.delete();
                    print(
                      'Arquivo de comprovante removido: ${comprovante.caminhoArquivo}',
                    );
                  }
                } catch (e) {
                  print('Erro ao remover arquivo de comprovante: $e');
                }

                await _banco.removerComprovante(comprovante.id!);
                _carregarComprovantes();
                Navigator.of(context).pop();
                if (mounted) {
                  showSnackBarMessage(context, 'Comprovante removido!');
                }
              },
              child: Text(
                'Remover',
                style: TextStyle(color: ComandasApp.errorColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Comprovantes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _comprovantes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 100,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Nenhum comprovante adicionado ainda.\nClique no botão "+" para capturar ou escolher uma foto!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _comprovantes.length,
              itemBuilder: (context, index) {
                final comprovante = _comprovantes[index];
                return GestureDetector(
                  onTap: () => _abrirImagemComprovante(comprovante),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(comprovante.caminhoArquivo),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 4.0,
                            ),
                            child: Text(
                              comprovante.descricao ?? 'Comprovante',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
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
                    _tirarFotoOuEscolherGaleria(ImageSource.camera);
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
                    _tirarFotoOuEscolherGaleria(ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add_a_photo),
        tooltip: 'Adicionar Comprovante',
      ),
    );
  }
}

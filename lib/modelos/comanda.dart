import 'package:flutter_comandas_app/modelos/item_comanda.dart';

class Comanda {
  final int? id;
  String nome;
  final DateTime dataCriacao;
  List<ItemComanda> itens;

  Comanda({
    this.id,
    required this.nome,
    DateTime? dataCriacao,
    List<ItemComanda>? itens,
  }) : dataCriacao = dataCriacao ?? DateTime.now(),
       itens = itens ?? [];

  double get total {
    return itens.fold(0.0, (soma, item) => soma + item.total);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'data_criacao': dataCriacao.toIso8601String(),
    };
  }

  factory Comanda.fromMap(Map<String, dynamic> map) {
    return Comanda(
      id: map['id'] as int?,
      nome: map['nome'] ?? '',
      dataCriacao: DateTime.parse(map['data_criacao']),
      itens: [],
    );
  }

  Comanda copyWith({
    int? id,
    String? nome,
    DateTime? dataCriacao,
    List<ItemComanda>? itens,
  }) {
    return Comanda(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      itens: itens ?? this.itens,
    );
  }

  @override
  String toString() {
    return 'Comanda(id: $id, nome: $nome, dataCriacao: $dataCriacao, itens: $itens)';
  }
}

class ItemComanda {
  final int? id;
  final String nome;
  final int quantidade;
  final double preco;
  final String? caminhoFoto;

  ItemComanda({
    this.id,
    required this.nome,
    required this.quantidade,
    required this.preco,
    this.caminhoFoto,
  });

  double get total => quantidade * preco;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'quantidade': quantidade,
      'preco': preco,
      'caminho_foto': caminhoFoto,
    };
  }

  factory ItemComanda.fromMap(Map<String, dynamic> map) {
    return ItemComanda(
      id: map['id'] as int?,
      nome: map['nome'] ?? '',
      quantidade: map['quantidade'] ?? 0,
      preco: (map['preco'] is int)
          ? (map['preco'] as int).toDouble()
          : (map['preco'] as double?) ?? 0.0,
      caminhoFoto: map['caminho_foto'] as String?,
    );
  }

  ItemComanda copyWith({
    int? id,
    String? nome,
    int? quantidade,
    double? preco,
    String? caminhoFoto,
  }) {
    return ItemComanda(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      preco: preco ?? this.preco,
      caminhoFoto: caminhoFoto ?? this.caminhoFoto,
    );
  }

  @override
  String toString() {
    return 'ItemComanda(id: $id, nome: $nome, quantidade: $quantidade, preco: $preco, caminhoFoto: $caminhoFoto)';
  }
}

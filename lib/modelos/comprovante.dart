class Comprovante {
  int? id;
  String caminhoArquivo;
  DateTime dataCaptura;
  int? idComandaVinculada;
  String? descricao;

  Comprovante({
    this.id,
    required this.caminhoArquivo,
    required this.dataCaptura,
    this.idComandaVinculada,
    this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caminhoArquivo': caminhoArquivo,
      'dataCaptura': dataCaptura.toIso8601String(),
      'idComandaVinculada': idComandaVinculada,
      'descricao': descricao,
    };
  }

  factory Comprovante.fromMap(Map<String, dynamic> map) {
    return Comprovante(
      id: map['id'] as int?,
      caminhoArquivo: map['caminhoArquivo'] as String,
      dataCaptura: DateTime.parse(map['dataCaptura'] as String),
      idComandaVinculada: map['idComandaVinculada'] as int?,
      descricao: map['descricao'] as String?,
    );
  }

  @override
  String toString() {
    return 'Comprovante(id: $id, caminhoArquivo: $caminhoArquivo, dataCaptura: $dataCaptura, idComandaVinculada: $idComandaVinculada, descricao: $descricao)';
  }
}

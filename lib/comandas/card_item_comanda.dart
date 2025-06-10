import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_comandas_app/modelos/item_comanda.dart';
import 'package:intl/intl.dart';
import 'package:flutter_comandas_app/main.dart';

class ComandaItemCard extends StatelessWidget {
  final ItemComanda item;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const ComandaItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String precoUnitarioFormatado = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(item.preco);
    final String totalItemFormatado = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(item.total);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildItemImage(context, item.caminhoFoto),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Qtd: ${item.quantidade} | Preço Unit.: $precoUnitarioFormatado',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalItemFormatado,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ComandasApp.successColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: ComandasApp.errorColor,
                        size: 22,
                      ),
                      onPressed: onRemove,
                      tooltip: 'Remover Item',
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(BuildContext context, String? imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 70,
        height: 70,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: imagePath != null && imagePath.isNotEmpty
            ? Image.file(
                File(imagePath),
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image,
                    size: 35,
                    color: Theme.of(context).colorScheme.error,
                  );
                },
              )
            : Icon(
                Icons.fastfood,
                size: 35,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
      ),
    );
  }
}

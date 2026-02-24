<div align="center">

# 🍽️ Comanda App

**Aplicativo mobile para gerenciamento de pedidos e mesas em bares e restaurantes.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![SQLite](https://img.shields.io/badge/SQLite-Local-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org/)

🎬 **[Ver demonstração em vídeo](https://www.youtube.com/watch?v=8jjA6eFz0s4)**

</div>

---

## 📋 Sobre o Projeto

O **Comanda App** é um aplicativo Flutter para gerenciamento de comandas em estabelecimentos como bares e restaurantes. Permite registrar pedidos por mesa, cadastrar itens com imagens, controlar o status dos pedidos e gerar totalizações — tudo armazenado localmente via SQLite sem necessidade de conexão com internet.

---

## ✨ Funcionalidades

- 📋 Criação e gerenciamento de comandas por mesa
- 🍕 Cadastro de itens com foto, nome e preço
- 💰 Cálculo automático de totais
- 📅 Formatação de datas e valores monetários em pt-BR
- 📷 Seleção de imagens da galeria ou câmera
- 💾 Persistência local com banco de dados SQLite

---

## 🚀 Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| [Flutter](https://flutter.dev/) | 3.x | Framework de UI multiplataforma |
| [Dart](https://dart.dev/) | 3.8.x | Linguagem de programação |
| [sqflite](https://pub.dev/packages/sqflite) | 2.3.x | Banco de dados SQLite local |
| [path_provider](https://pub.dev/packages/path_provider) | 2.1.x | Acesso a diretórios do sistema |
| [intl](https://pub.dev/packages/intl) | 0.20.x | Formatação de datas e moedas |
| [image_picker](https://pub.dev/packages/image_picker) | 1.1.x | Seleção de imagens |

---

## 📱 Plataformas Suportadas

- Android ✅
- iOS ✅
- Web ✅
- Windows ✅

---

## ⚙️ Como Executar

```bash
# Instalar dependências
flutter pub get

# Rodar em desenvolvimento
flutter run

# Build para Android
flutter build apk
```

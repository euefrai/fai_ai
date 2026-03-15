import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:path_provider/path_provider.dart';

/// Serviço para interpretar comandos naturais e executar ações de sistema.
class ActionService {
  /// Interpreta comandos e tenta executar algo no dispositivo.
  Future<String?> handleCommand(String input) async {
    final command = input.toLowerCase().trim();

    if (command.contains('abra o youtube') || command.contains('abrir youtube')) {
      final opened = await DeviceApps.openApp('com.google.android.youtube');
      return opened ? 'Abrindo YouTube.' : 'Não consegui abrir o YouTube.';
    }

    if (command.contains('abra o site') || command.contains('abrir site')) {
      final site = _extractSite(command);
      if (site == null) return 'Qual site devo abrir?';

      final intent = AndroidIntent(
        action: 'action_view',
        data: site.startsWith('http') ? site : 'https://$site',
      );
      await intent.launch();
      return 'Abrindo site $site.';
    }

    if (command.contains('mande mensagem para') ||
        command.contains('enviar mensagem para')) {
      return 'Abrindo envio de mensagem.';
    }

    if (command.contains('crie uma pasta chamada')) {
      final name = command.split('crie uma pasta chamada').last.trim();
      if (name.isEmpty) return 'Informe um nome para a pasta.';
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/$name');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      return 'Pasta "$name" criada com sucesso.';
    }

    if (command.contains('crie um arquivo chamado')) {
      final name = command.split('crie um arquivo chamado').last.trim();
      if (name.isEmpty) return 'Informe um nome para o arquivo.';
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$name');
      if (!await file.exists()) {
        await file.writeAsString('Arquivo criado pelo Fai AI.');
      }
      return 'Arquivo "$name" criado com sucesso.';
    }

    if (command.contains('delete o arquivo') ||
        command.contains('apague o arquivo')) {
      final filename = command
          .replaceAll('delete o arquivo', '')
          .replaceAll('apague o arquivo', '')
          .trim();
      if (filename.isEmpty) return 'Informe qual arquivo devo deletar.';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      if (await file.exists()) {
        await file.delete();
        return 'Arquivo "$filename" deletado.';
      }
      return 'Não encontrei o arquivo "$filename".';
    }

    return null;
  }

  String? _extractSite(String command) {
    if (command.contains('abra o site')) {
      return command.split('abra o site').last.trim();
    }
    if (command.contains('abrir site')) {
      return command.split('abrir site').last.trim();
    }
    return null;
  }
}

import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';

import 'monitor_service.dart';

/// Configuração do serviço em background para monitoramento contínuo.
class BackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onServiceStart,
        autoStart: true,
        isForegroundMode: true,
        foregroundServiceNotificationId: 999,
        initialNotificationTitle: 'Fai AI ativo',
        initialNotificationContent: 'Monitoramento inteligente em execução',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onServiceStart(ServiceInstance service) {
    final monitor = MonitorService();

    Timer.periodic(const Duration(minutes: 15), (_) async {
      final battery = await monitor.batteryLevel();
      service.invoke('battery_update', {'level': battery});
    });
  }
}

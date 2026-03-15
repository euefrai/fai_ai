import 'package:battery_plus/battery_plus.dart';
import 'package:device_apps/device_apps.dart';
import 'package:geolocator/geolocator.dart';

/// Serviço para monitorar status do dispositivo.
class MonitorService {
  final Battery _battery = Battery();

  Future<int> batteryLevel() async {
    return _battery.batteryLevel;
  }

  Future<String> currentLocationText() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Localização desativada no aparelho.';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'Sem permissão de localização.';
    }

    final pos = await Geolocator.getCurrentPosition();
    return 'Você está em latitude ${pos.latitude.toStringAsFixed(5)} e longitude ${pos.longitude.toStringAsFixed(5)}.';
  }

  Future<List<String>> installedApps({int limit = 10}) async {
    final apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: false,
      includeAppIcons: false,
      onlyAppsWithLaunchIntent: true,
    );

    final names = apps.map((e) => e.appName).toList()..sort();
    return names.take(limit).toList();
  }
}

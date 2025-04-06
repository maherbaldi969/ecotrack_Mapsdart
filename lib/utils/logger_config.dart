import 'package:logging/logging.dart';

class LoggerConfig {
  static void initialize() {
    // Configuration du niveau de log
    Logger.root.level = Level.INFO;
    
    // Configuration du handler des logs
    Logger.root.onRecord.listen((record) {
      final logMessage = StringBuffer()
        ..write('${record.level.name}: ')
        ..write('${record.time}: ')
        ..write(record.message);
      
      if (record.error != null) {
        logMessage.write('\nError: ${record.error}');
      }
      
      if (record.stackTrace != null) {
        logMessage.write('\nStackTrace: ${record.stackTrace}');
      }
      
      print(logMessage.toString());
    });
  }

  static Logger getLogger(String name) {
    return Logger(name);
  }
}

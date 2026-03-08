import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/services/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = await LocalStorage.create();
  runApp(MyApp(storage: storage));
}

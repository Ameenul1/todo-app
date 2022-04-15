import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '/Screens/loading_screen.dart';
import '/providers/task_provider.dart';
import 'package:provider/provider.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Colors.pinkAccent,
          ledColor: Colors.white,
          groupKey: "todo",
          importance: NotificationImportance.High,
          enableVibration: true,
          defaultPrivacy: NotificationPrivacy.Public,
          playSound: true,
        )
      ]
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: TaskProvider(),
      child: const Material(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LoadingScreen(),
        ),
      ),
    );
  }


}




import 'package:flutter/material.dart';
import '/Screens/home_screen.dart';
import '/providers/task_provider.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<TaskProvider>(context,listen: false).fetchAndSetTask(),
        builder: (context,snap) => (snap.connectionState==ConnectionState.waiting)?const Center(child: CircularProgressIndicator(),):const HomeScreen(),
      ),
    );
  }
}

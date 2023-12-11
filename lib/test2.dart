import 'package:flutter/material.dart';
import 'package:flutter_notification/test.dart';
import 'package:typethis/typethis.dart';

class Test2 extends StatefulWidget {
  const Test2({Key? key}) : super(key: key);

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  final typeThisWidget = TypeThis(
    // The text which will be animated.
    string: 'Seni Çok seviyorum Mehmet Kurt...',
    // Speed in milliseconds at which the typing animation will be executed.
    speed: 100,
    // Text style for the string.
    style: const TextStyle(fontSize: 20,color: Colors.black),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomDecoratedBox(typeThisWidget: typeThisWidget),


        ],
      ),
    );
  }
}

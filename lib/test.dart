import 'package:flutter/material.dart';
import 'package:typethis/typethis.dart';

class TypeThisTest extends StatefulWidget {
  const TypeThisTest({Key? key}) : super(key: key);

  @override
  State<TypeThisTest> createState() => _TypeThisTestState();
}

class _TypeThisTestState extends State<TypeThisTest> {



  final typeThisWidget = TypeThis(
    // The text which will be animated.
    string: 'Bluetooth Taramak İçin Lütfen Tıklayın?',
    // Speed in milliseconds at which the typing animation will be executed.
    speed: 100,
    softWrap: true,
    // Text style for the string.
    style: const TextStyle(fontSize: 16,color: Colors.red),
  );
  final typeThisWidget2 = TypeThis(
    // The text which will be animated.
    string: 'Eninde sonunda her şey yoluna giricek merak etme...',
    softWrap: true,

    // Speed in milliseconds at which the typing animation will be executed.
    speed: 100,
    // Text style for the string.
    style: const TextStyle(fontSize: 16,color: Colors.blue),
  );
  final typeThisWidget3 = TypeThis(
    // The text which will be animated.
    string: 'Eninde sonunda her şey yoluna giricek merak etme...',
    softWrap: true,

    // Speed in milliseconds at which the typing animation will be executed.
    speed: 100,
    // Text style for the string.
    style: const TextStyle(fontSize: 16,color: Colors.blue),
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TypeThis Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('TypeThis Example'),
          backgroundColor: Colors.grey[200],
        ),
        body: Center(
          child: Column(
            children: [
            SizedBox(height: 300,),
                  CustomDecoratedBox(
                    typeThisWidget: typeThisWidget,
                  ),
              CustomDecoratedBox(
                typeThisWidget: typeThisWidget2,
              ),
              CustomDecoratedBox(
                typeThisWidget: typeThisWidget3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


  class CustomDecoratedBox extends StatelessWidget {
  final TypeThis typeThisWidget;


  const CustomDecoratedBox({
    required this.typeThisWidget,

  });

  @override
  Widget build(BuildContext context) {
    // Implement the UI for your CustomDecoratedBox here
    return Container(
      child: Column(
        children: [
          typeThisWidget,
        ],
      ),
    );
  }
}


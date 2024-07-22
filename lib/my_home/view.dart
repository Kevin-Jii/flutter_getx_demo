import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  final logic = Get.put(MyHomeLogic());
  final state = Get.find<MyHomeLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

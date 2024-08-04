import 'package:flutter/material.dart';
import 'package:flutter_getx_template/components/custom_appbar.dart';
import 'package:get/get.dart';

import '../../components/custom_scaffold.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: MyAppBar(
        centerTitle: false, // 确保标题不居中
        title: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft, // 左对齐
                child: MyTitle('首页'),
              ),
            ),
          ],
        ),
        leadingType: AppBarBackType.None,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Center(child: Text(controller.count.toString()))),
            TextButton(
                onPressed: () => controller.increment(),
                child: Text('count++')),
            GetBuilder<HomeController>(builder: (_) {
              return Text(controller.userName);
            }),
            TextButton(
                onPressed: () => controller.changeUserName(),
                child: Text('changeName')),
          ],
        ),
      ),
    );
  }
}

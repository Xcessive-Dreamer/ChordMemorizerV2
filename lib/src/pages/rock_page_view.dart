// rock_page_view.dart

import 'package:flutter/material.dart';

class RockPageView extends StatelessWidget {
  const RockPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rock Page'),
      ),
      body: const Center(
        child: Text('Rock Page Content'),
      ),
    );
  }
}

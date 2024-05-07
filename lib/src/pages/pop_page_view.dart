// pop_page_view.dart

import 'package:flutter/material.dart';

class PopPageView extends StatelessWidget {
  const PopPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pop Page'),
      ),
      body: const Center(
        child: Text('Pop Page Content'),
      ),
    );
  }
}

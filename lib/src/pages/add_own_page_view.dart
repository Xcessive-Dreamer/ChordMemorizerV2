import 'package:flutter/material.dart';

class AddOwnPageView extends StatelessWidget {
  const AddOwnPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Own Page'),
      ),
      body: const Center(
        child: Text('Add Own Page Content'),
      ),
    );
  }
}
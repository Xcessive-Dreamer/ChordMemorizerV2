// country_page_view.dart

import 'package:flutter/material.dart';

class CountryPageView extends StatelessWidget {
  const CountryPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Page'),
      ),
      body: const Center(
        child: Text('Country Page Content'),
      ),
    );
  }
}

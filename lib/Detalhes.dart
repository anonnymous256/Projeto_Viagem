import 'package:flutter/material.dart';

class DetalhesViagemScreen extends StatelessWidget {
  final String title;
  final String description;
  final double budget;
  final String image;

  DetalhesViagemScreen({
    required this.title,
    required this.description,
    required this.budget,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Viagem'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            image,
            width: MediaQuery.of(context).size.width,
            height: 200,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(description),
                SizedBox(height: 8),
                Text('Orçamento: R\$ ${budget.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

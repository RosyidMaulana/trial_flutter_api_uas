import 'dart:io';
import 'package:flutter/material.dart';
import '../models/finance_model.dart';
import '../services/finance_service.dart';
import 'form_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Finance>> _finances;

  @override
  void initState() {
    super.initState();
    _loadFinances();
  }

  void _loadFinances() {
    _finances = FinanceService.getAllFinances();
  }

  void _refreshData() {
    setState(() {
      _loadFinances();
    });
  }

  Widget _buildFinanceCard(Finance finance) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: finance.photoUrl != null
            ? Image.network(
                finance.photoUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.receipt_long, size: 40),
        title: Text(finance.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rp${finance.amount} - ${finance.type}'),
            Text(finance.date),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(financeId: finance.id!),
            ),
          );
          _refreshData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan'),
      ),
      body: FutureBuilder<List<Finance>>(
        future: _finances,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada catatan keuangan.'));
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                _refreshData();
              },
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  return _buildFinanceCard(snapshot.data![index]);
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          );
          if (result == true) {
            _refreshData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

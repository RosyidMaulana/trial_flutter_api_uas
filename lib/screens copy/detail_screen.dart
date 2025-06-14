import 'package:flutter/material.dart';
import '../models/finance_model.dart';
import '../services/finance_service.dart';
import 'form_screen.dart';

class DetailScreen extends StatefulWidget {
  final int financeId;

  const DetailScreen({super.key, required this.financeId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Finance> _finance;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    _finance = FinanceService.getFinanceById(widget.financeId);
  }

  void _refresh() {
    setState(() {
      _loadDetail();
    });
  }

  Future<void> _deleteFinance(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FinanceService.deleteFinance(id);
        if (mounted) Navigator.pop(context); // Kembali ke Home
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Keuangan')),
      body: FutureBuilder<Finance>(
        future: _finance,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                if (data.photoUrl != null)
                  Image.network(
                    data.photoUrl!,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                else
                  const Icon(Icons.receipt_long, size: 100),
                const SizedBox(height: 16),
                Text(data.title, style: Theme.of(context).textTheme.headlineSmall),
                Text('Jenis: ${data.type}'),
                Text('Tanggal: ${data.date}'),
                Text('Jumlah: Rp${data.amount}'),
                const SizedBox(height: 8),
                Text('Deskripsi:', style: Theme.of(context).textTheme.titleMedium),
                Text(data.description),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormScreen(finance: data),
                          ),
                        );
                        _refresh(); // refresh setelah update
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _deleteFinance(data.id!),
                      icon: const Icon(Icons.delete),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      label: const Text('Hapus'),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

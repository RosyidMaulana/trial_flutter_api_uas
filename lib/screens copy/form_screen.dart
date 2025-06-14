import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/finance_model.dart';
import '../services/finance_service.dart';

class FormScreen extends StatefulWidget {
  final Finance? finance; // untuk edit mode (opsional)

  const FormScreen({super.key, this.finance});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  String _type = 'Pengeluaran';
  File? _photo;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.finance?.title ?? '');
    _amountController =
        TextEditingController(text: widget.finance?.amount.toString() ?? '');
    _dateController = TextEditingController(text: widget.finance?.date ?? '');
    _descriptionController =
        TextEditingController(text: widget.finance?.description ?? '');
    _type = widget.finance?.type ?? 'Pengeluaran';
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final finance = Finance(
        id: widget.finance?.id,
        title: _titleController.text,
        type: _type,
        date: _dateController.text,
        amount: int.tryParse(_amountController.text) ?? 0,
        description: _descriptionController.text,
        photoUrl: null, // Tidak perlu diset, backend yang akan berikan
      );

      try {
        if (widget.finance != null) {
          await FinanceService.updateFinance(finance.id!, finance, _photo);
        } else {
          await FinanceService.createFinance(finance, _photo);
        }
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.finance != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Keuangan' : 'Tambah Keuangan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Judul wajib diisi' : null,
              ),
              DropdownButtonFormField(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'Pengeluaran', child: Text('Pengeluaran')),
                  DropdownMenuItem(value: 'Pemasukan', child: Text('Pemasukan')),
                ],
                onChanged: (value) => setState(() => _type = value!),
                decoration: const InputDecoration(labelText: 'Jenis'),
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Tanggal wajib diisi' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah (Rupiah)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Jumlah wajib diisi' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              _photo != null
                  ? Image.file(_photo!, height: 120)
                  : const Text('Belum ada foto'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text('Galeri'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? 'Update' : 'Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

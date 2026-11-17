import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:8080/toko-api/public/index.php';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Kita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

// ==================== MODEL PRODUK ====================
class Produk {
  final int? id;
  final String? kodeProduk;
  final String? namaProduk;
  final int? harga;

  Produk({this.id, this.kodeProduk, this.namaProduk, this.harga});

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: int.tryParse(json['id'].toString()),
      kodeProduk: json['kode_produk']?.toString(),
      namaProduk: json['nama_produk']?.toString(),
      harga: int.tryParse(json['harga'].toString()),
    );
  }
}

// ==================== HALAMAN LOGIN ====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final result = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200 && result['status'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProdukPage()),
        );
      } else {
        _showError(result['data']?.toString() ?? 'Login gagal');
      }
    } catch (e) {
      if (mounted) _showError('Koneksi gagal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('GAGAL', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Email harus diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Password harus diisi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitLogin,
                  child: Text(_isLoading ? 'Memproses...' : 'Login'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistrasiPage()),
                  );
                },
                child: const Text('Registrasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HALAMAN REGISTRASI ====================
class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});

  @override
  State<RegistrasiPage> createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitRegistrasi() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registrasi'),
        body: {
          'nama': _namaController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final result = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200 && result['status'] == true) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('SUKSES', style: TextStyle(color: Colors.green)),
            content: const Text('Registrasi berhasil, silahkan login'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('GAGAL', style: TextStyle(color: Colors.red)),
            content: Text(result['data']?.toString() ?? 'Registrasi gagal'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('GAGAL', style: TextStyle(color: Colors.red)),
          content: Text('Koneksi gagal: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (val) => val == null || val.length < 3
                    ? 'Nama minimal 3 karakter'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Email harus diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) => val == null || val.length < 6
                    ? 'Password minimal 6 karakter'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _konfirmasiController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Konfirmasi Password'),
                validator: (val) => val != _passwordController.text
                    ? 'Konfirmasi Password tidak sama'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRegistrasi,
                  child: Text(_isLoading ? 'Memproses...' : 'Registrasi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HALAMAN DAFTAR PRODUK (READ) ====================
class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  late Future<List<Produk>> _futureProduk;

  @override
  void initState() {
    super.initState();
    _futureProduk = _fetchProduk();
  }

  Future<List<Produk>> _fetchProduk() async {
    final response = await http.get(Uri.parse('$baseUrl/produk'));
    final result = jsonDecode(response.body);
    final List listData = result['data'] ?? [];
    return listData.map((item) => Produk.fromJson(item)).toList();
  }

  void _refreshData() {
    setState(() {
      _futureProduk = _fetchProduk();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            tooltip: 'Tambah Produk',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProdukForm()),
              );
              _refreshData();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Produk>>(
        future: _futureProduk,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final produkList = snapshot.data ?? [];
          if (produkList.isEmpty) {
            return const Center(
              child: Text('Belum ada produk. Tekan + di kanan atas untuk menambah.'),
            );
          }
          return ListView.builder(
            itemCount: produkList.length,
            itemBuilder: (context, index) {
              final produk = produkList[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProdukDetail(produk: produk),
                    ),
                  );
                  _refreshData();
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(produk.namaProduk ?? ''),
                    subtitle: Text('Rp ${produk.harga}'),
                    trailing: Text(produk.kodeProduk ?? ''),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== HALAMAN FORM TAMBAH & UBAH PRODUK ====================
class ProdukForm extends StatefulWidget {
  final Produk? produk;
  const ProdukForm({super.key, this.produk});

  @override
  State<ProdukForm> createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  bool _isLoading = false;

  bool get _isEdit => widget.produk != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _kodeController.text = widget.produk!.kodeProduk ?? '';
      _namaController.text = widget.produk!.namaProduk ?? '';
      _hargaController.text = widget.produk!.harga?.toString() ?? '';
    }
  }

  Future<void> _simpanProduk() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final bodyData = {
        'kode_produk': _kodeController.text,
        'nama_produk': _namaController.text,
        'harga': _hargaController.text,
      };

      final response = _isEdit
          ? await http.put(
              Uri.parse('$baseUrl/produk/${widget.produk!.id}'),
              body: bodyData,
            )
          : await http.post(
              Uri.parse('$baseUrl/produk'),
              body: bodyData,
            );

      final result = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200 && result['status'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ProdukPage()),
          (route) => false,
        );
      } else {
        _showError(
            _isEdit ? 'Ubah data gagal, silahkan coba lagi' : 'Simpan gagal');
      }
    } catch (e) {
      if (mounted) _showError('Koneksi gagal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('GAGAL', style: TextStyle(color: Colors.red)),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Produk' : 'Tambah Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _kodeController,
                decoration: const InputDecoration(labelText: 'Kode Produk'),
                validator: (val) => val == null || val.isEmpty
                    ? 'Kode Produk harus diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (val) => val == null || val.isEmpty
                    ? 'Nama Produk harus diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Harga harus diisi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanProduk,
                  child: Text(_isLoading
                      ? 'Menyimpan...'
                      : (_isEdit ? 'UBAH' : 'SIMPAN')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HALAMAN DETAIL & HAPUS PRODUK ====================
class ProdukDetail extends StatefulWidget {
  final Produk produk;
  const ProdukDetail({super.key, required this.produk});

  @override
  State<ProdukDetail> createState() => _ProdukDetailState();
}

class _ProdukDetailState extends State<ProdukDetail> {
  Future<void> _hapusProduk() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/produk/${widget.produk.id}'),
      );
      final result = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200 && result['status'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ProdukPage()),
          (route) => false,
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('GAGAL', style: TextStyle(color: Colors.red)),
            content: const Text('Hapus gagal, silahkan coba lagi'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('GAGAL', style: TextStyle(color: Colors.red)),
          content: Text('Koneksi gagal: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _confirmHapus() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _hapusProduk();
            },
            child: const Text('Ya'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kode : ${widget.produk.kodeProduk}',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 8),
            Text(
              'Nama : ${widget.produk.namaProduk}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 8),
            Text(
              'Harga : Rp. ${widget.produk.harga}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProdukForm(produk: widget.produk),
                      ),
                    );
                  },
                  child: const Text('EDIT'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _confirmHapus,
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/package_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String _status = "Ready to download assignment player";
  double? _progress;

  Future<void> _startProcess() async {
    setState(() {
      _isLoading = true;
      _status = "Initializing...";
      _progress = 0.0;
    });

    final packageService = PackageService();

    final indexPath = await packageService.downloadAndProcessPackage(
      onProgress: (status, progress) {
        setState(() {
          _status = status;
          _progress = progress;
        });
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (indexPath != null && mounted) {
      context.pushNamed('Player', extra: indexPath);
    } else {
      setState(() {
        _status = "Failed to handle package assets correctly.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent,
        title: const Text('Liqvid Assignment Rudransh'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              if (_isLoading) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 10),
                if (_progress != null)
                  Text('${(_progress! * 100).toStringAsFixed(1)}%'),
              ] else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  onPressed: _startProcess,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: const Text(
                      'Initialize & Launch Player',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

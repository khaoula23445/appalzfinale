import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:alzheimer_app/alzhimer_home/alzhimer_app_theme.dart';

class BraceletPairingPage extends StatefulWidget {
  const BraceletPairingPage({Key? key}) : super(key: key);

  @override
  _BraceletPairingPageState createState() => _BraceletPairingPageState();
}

class _BraceletPairingPageState extends State<BraceletPairingPage> {
  // Color scheme
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _accentColor = Color(0xFFFF5252);
  static const Color _successColor = Color(0xFF4CAF50);

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedCode = '';
  bool isScanning = true;
  bool isValidCode = false;
  Map<String, dynamic>? patientData;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning) {
        setState(() {
          scannedCode = scanData.code ?? '';
          isScanning = false;
          _validateCode(scannedCode);
        });
      }
    });
  }

  void _validateCode(String code) async {
    // Simulate API call to validate code and fetch patient data
    await Future.delayed(const Duration(seconds: 1));
    
    // This would be replaced with actual API call
    if (code.startsWith('ALZBR')) { // Sample validation
      setState(() {
        isValidCode = true;
        patientData = {
          'name': 'Mohamed Ali',
          'age': 72,
          'condition': 'Moderate Alzheimer',
          'contact': '+213123456789',
          'braceletId': code,
          'lastLocation': '36.7525, 3.0420' // Algiers coordinates
        };
      });
    } else {
      setState(() {
        isValidCode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid bracelet code'),
          backgroundColor: _accentColor,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _resetScanner(),
          ),
        ),
      );
    }
  }

  void _resetScanner() {
    setState(() {
      isScanning = true;
      scannedCode = '';
      patientData = null;
    });
    controller?.resumeCamera();
  }

  void _confirmPairing() {
    // In real app, this would save the pairing to backend
    Navigator.pop(context, patientData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Pair Bracelet",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: _buildScannerView(),
          ),
          Expanded(
            flex: patientData != null ? 4 : 2,
            child: _buildInfoPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: _primaryColor,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.7,
          ),
        ),
        if (isScanning)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Scan Bracelet QR Code",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SvgPicture.asset(
                'assets/qr_scan_icon.svg', // Add your own SVG asset
                color: Colors.white,
                width: 60,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (patientData != null) ...[
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Name', patientData!['name']),
                    _buildDetailRow('Age', patientData!['age'].toString()),
                    _buildDetailRow('Condition', patientData!['condition']),
                    _buildDetailRow('Contact', patientData!['contact']),
                    _buildDetailRow('Bracelet ID', patientData!['braceletId']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _accentColor),
                    ),
                    onPressed: _resetScanner,
                    child: Text(
                      'SCAN AGAIN',
                      style: TextStyle(color: _accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _successColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _confirmPairing,
                    child: const Text(
                      'CONFIRM PAIRING',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              "Point your camera at the QR code on the patient's bracelet",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.arrow_downward,
              size: 40,
              color: _primaryColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Import untuk Clipboard
import 'package:qr_flutter/qr_flutter.dart'; // Import untuk QRIS
import 'payment_receipt_page.dart'; // Import ReceiptPage
import '../services/firebase.dart'; // Import FirestoreService

class PaymentPage extends StatelessWidget {
  final String namaTiket;
  final String kategori;
  final int harga;
  final DateTime tanggal;
  final FirestoreService firestoreService = FirestoreService();
  PaymentPage({
    super.key,
    required this.namaTiket,
    required this.kategori,
    required this.harga,
    required this.tanggal,
  });

  String _formatDate(DateTime date) {
    final Map<int, String> monthNames = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'Mei',
      6: 'Jun',
      7: 'Jul',
      8: 'Agu',
      9: 'Sep',
      10: 'Okt',
      11: 'Nov',
      12: 'Des',
    };
    return '${date.day} ${monthNames[date.month]} ${date.year}';
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna latar belakang utama
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF1F2937)), // Warna ikon back
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pembayaran',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937), // Warna teks title
            fontWeight: FontWeight.w600, // Semi-bold
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.grey[50], // Warna AppBar sama dengan body
        centerTitle: true,
        elevation: 0, // Hilangkan shadow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20.0, vertical: 20.0), // Padding disesuaikan
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Total Tagihan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20), // Padding dalam card
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // Radius border card
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2), // Sedikit shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, // Ukuran ikon container
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE0E7FF), // Warna background ikon
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icon/receipt_lon.png', // Menggunakan ikon dari assets
                            width: 20, // Ukuran ikon
                            height: 20,
                            color: const Color(0xFF3730A3), // Warna ikon
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Tagihan',
                            style: GoogleFonts.poppins(
                              fontSize: 12, // Ukuran font lebih kecil
                              fontWeight: FontWeight.w500,
                              color:
                                  const Color(0xFF6B7280), // Warna teks abu-abu
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(harga),
                            style: GoogleFonts.poppins(
                              fontSize: 20, // Ukuran font harga
                              fontWeight: FontWeight.bold, // Bold
                              color:
                                  const Color(0xFF1F2937), // Warna teks hitam
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Jarak antar elemen
                  _buildInfoRow('Nama Pesanan', '$namaTiket - $kategori'),
                  const SizedBox(height: 6),
                  _buildInfoRow('Tanggal', _formatDate(tanggal)),
                ],
              ),
            ),
            const SizedBox(height: 28), // Jarak antar section

            // Pilih Metode Pembayaran Section
            Text(
              'Pilih Metode Pembayaran',
              style: GoogleFonts.poppins(
                fontSize: 14, // Ukuran font section title
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563), // Warna teks abu-abu gelap
              ),
            ),
            const SizedBox(height: 12),

            // Metode Pembayaran Options
            _buildPaymentOption(
              context: context,
              title: 'Tunai (Cash)',
              iconPath: 'assets/icon/wallet.png', // Path ikon dari assets
              onTap: () {
                _showCashPaymentDialog(context);
              },
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              context: context,
              title: 'Kartu Kredit',
              iconPath: 'assets/icon/credit_card.png', // Path ikon dari assets
              onTap: () {
                _showCreditCardPaymentDialog(context);
              },
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              context: context,
              title: 'QRIS / QR Pay',
              iconPath: 'assets/icon/qr_code.png', // Path ikon dari assets
              onTap: () {
                _showQrisPaymentPopup(context);
              },
            ),
            const SizedBox(height: 28),

            // Punya Pertanyaan? Section
            Text(
              'Punya pertanyaan?',
              style: GoogleFonts.poppins(
                fontSize: 12, // Ukuran font lebih kecil
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12), // Padding disesuaikan
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icon/help_outline.png', // Menggunakan ikon dari assets
                    width: 20, // Sesuaikan ukuran ikon jika perlu
                    height: 20, // Sesuaikan ukuran ikon jika perlu
                    color: const Color(0xFF3730A3), // Warna ikon
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hubungi Admin untuk bantuan pembayaran.',
                      style: GoogleFonts.poppins(
                        fontSize: 12, // Ukuran font
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151), // Warna teks
                      ),
                    ),
                  ),
                  // Tidak ada ikon panah kanan lagi sesuai gambar
                ],
              ),
            ),
            const SizedBox(height: 20), // Padding bawah
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12, // Ukuran font label
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12, // Ukuran font value
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151), // Warna teks value
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    required String iconPath, // Menggunakan path ikon string
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // Padding dalam opsi
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath, // Menggunakan Image.asset
              width: 20, // Ukuran ikon
              height: 20,
              // Tidak perlu color tint jika ikon sudah berwarna sesuai
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14, // Ukuran font title opsi
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFF9CA3AF)), // Warna ikon panah
          ],
        ),
      ),
    );
  }

  void _navigateToReceiptPage(
      BuildContext context, String paymentMethod) async {
    try {
      // Save purchase data to Firebase
      await firestoreService.createPurchase(
        namaTiket: namaTiket,
        kategori: kategori,
        harga: harga,
        tanggal: tanggal,
        paymentMethod: paymentMethod,
      );

      // Navigate to receipt page after successful save
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentReceiptPage(
              nama_tiket: namaTiket,
              kategori: kategori,
              harga: harga,
              tanggal: tanggal,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data pembelian: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCashPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pembayaran Tunai',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3468E7),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: 135 + 32,
                  height: 135 + 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/img/cash.png',
                    width: 135,
                    height: 135,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pembayaran Tunai',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jika pembayaran telah diterima, klik button konfirmasi pembayaran untuk menyelesaikan transaksi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _navigateToReceiptPage(context, 'cash');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3468E7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    'Konfirmasi Pembayaran',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreditCardPaymentDialog(BuildContext context) {
    final TextEditingController cardNumberController =
        TextEditingController(text: '8810 7766 1234 9876');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pembayaran Kartu Kredit',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3468E7),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: 135 + 32,
                  height: 135 + 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/img/credit-card.png',
                    width: 135,
                    height: 135,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cardNumberController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: cardNumberController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Nomor Kartu Kredit Disalin!')),
                          );
                        },
                        child: Text(
                          'Salin',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3468E7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Transfer Pembayaran',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan nominal dan tujuan pembayaran sudah benar sebelum melanjutkan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _navigateToReceiptPage(context, 'credit_card');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3468E7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    'Konfirmasi Pembayaran',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQrisPaymentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16.0), // Rounded corners for the dialog
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Adjusted padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Pembayaran QRIS',
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB), // Blue color for title
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.grey[400]), // Lighter close icon
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Container(
                  padding: const EdgeInsets.all(8.0), // Padding around QR code
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data:
                        'https://gopay.co.id/merchant/qris', // Example QR data
                    version: QrVersions.auto,
                    size: 180.0, // Adjusted size
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    errorStateBuilder: (cxt, err) {
                      return Container(
                        width: 180.0,
                        height: 180.0,
                        alignment: Alignment.center,
                        child: Text(
                          'Oops! Gagal memuat QR Code.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Scan QR untuk Membayar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.black87, // Darker text
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Gunakan aplikasi e-wallet atau mobile banking untuk scan QR di atas dan selesaikan pembayaran',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.0, // Smaller font size
                    color: Colors.grey[600], // Lighter grey for description
                  ),
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _navigateToReceiptPage(context, 'qris');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2563EB), // Blue button color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0), // Adjusted padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12.0), // More rounded corners
                      ),
                      elevation: 0, // No shadow for a flatter look if desired
                    ),
                    child: Text(
                      'Konfirmasi Pembayaran',
                      style: GoogleFonts.poppins(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

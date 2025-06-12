// lib/ticket_list_page.dart atau lib/pages/ticket_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ticketingapp/services/firebase.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticketingapp/pages/payment_page.dart';
import 'package:ticketingapp/pages/purchase_history_page.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final FirestoreService firestoreService = FirestoreService();

  get tanggalPembelian => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ticketing App',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937), // Warna teks AppBar
            fontWeight: FontWeight.w600, // Membuat teks lebih tebal
            fontSize: 18, // Sedikit memperbesar font size
          ),
        ),
        backgroundColor: Colors.grey[50], // Warna latar AppBar sedikit abu-abu
        centerTitle: true,
        elevation: 0, // Menghilangkan shadow AppBar
        actions: [
          // Add history button
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF1F2937)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PurchaseHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100], // Warna latar belakang body
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTickets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            dynamic error = snapshot.error;
            String errorMessage = "Terjadi kesalahan yang tidak diketahui.";

            if (error is FirebaseException) {
              errorMessage = "Firebase Error: ${error.code} - ${error.message}";
            } else if (error is TypeError &&
                error.toString().contains('FirebaseException')) {
              errorMessage =
                  "Kesalahan dalam memproses data Firebase di Web. Mohon coba lagi.";
              print("Original Web TypeError: $error");
            } else {
              errorMessage = "Kesalahan: $error";
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tidak ada tiket."));
          } else {
            final tickets = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot doc = tickets[index];
                final data = doc.data() as Map<String, dynamic>;

                final String namaTiket =
                    data['nama_tiket'] ?? 'Nama Tiket Tidak Ada';
                final String kategori =
                    data['kategori'] ?? 'Kategori Tidak Ada';

                int harga;
                dynamic rawHarga = data['harga'];

                if (rawHarga is int) {
                  harga = rawHarga;
                } else if (rawHarga is String) {
                  try {
                    harga = int.parse(rawHarga);
                  } catch (e) {
                    print(
                        "Error parsing harga (String to int): $e. Harga yang didapatkan: $rawHarga");
                    harga = 0;
                  }
                } else {
                  print(
                      "Tipe data harga tidak dikenal: $rawHarga. Defaulting to 0.");
                  harga = 0;
                }

                final dynamic rawTanggal = data['tanggal'];
                DateTime tanggal;

                if (rawTanggal is Timestamp) {
                  tanggal = rawTanggal.toDate();
                } else {
                  print(
                      "Warning: 'tanggal' field is missing or not a Timestamp. Using current date.");
                  tanggal = DateTime.now();
                }

                return Card(
                  elevation: 1, // Mengurangi shadow card
                  margin: const EdgeInsets.only(bottom: 16), // Jarak antar card
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Radius border card
                  ),
                  color: Colors.white, // Warna card putih
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Align items vertically center
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                namaTiket,
                                style: GoogleFonts.poppins(
                                  fontWeight:
                                      FontWeight.w600, // Font weight semi-bold
                                  fontSize: 16, // Ukuran font nama tiket
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(
                                  height:
                                      2), // Jarak kecil antara nama dan kategori
                              Text(
                                kategori,
                                style: GoogleFonts.poppins(
                                  fontSize: 12, // Ukuran font kategori
                                  color:
                                      Colors.grey[600], // Warna font kategori
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(
                                  height: 6), // Jarak antara kategori dan harga
                              Text(
                                'Rp. ${harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight
                                      .bold, // Font weight bold untuk harga
                                  fontSize: 16, // Ukuran font harga
                                  color: const Color(
                                      0xFF2563EB), // Warna harga biru
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                    namaTiket: namaTiket,
                                    kategori: kategori,
                                    harga: harga,
                                    tanggal: tanggal),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart,
                              size: 16,
                              color: Colors.white), // Warna ikon putih
                          label: Text('Beli',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)), // Teks tombol
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2563EB), // Warna tombol biru
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8), // Padding tombol
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Radius border tombol
                            ),
                            elevation: 0, // Menghilangkan shadow tombol
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

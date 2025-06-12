// services/firebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference ticketsCollection =
      FirebaseFirestore.instance.collection("ticket");
  final CollectionReference purchasesCollection =
      FirebaseFirestore.instance.collection("purchases");

  Stream<QuerySnapshot> getTickets() {
    final streamTickets =
        ticketsCollection.orderBy("tanggal", descending: true).snapshots();
    return streamTickets;
  }

  Future<void> createPurchase({
    required String namaTiket,
    required String kategori,
    required int harga,
    required DateTime tanggal,
    required String paymentMethod,
  }) async {
    try {
      await purchasesCollection.add({
        'nama_tiket': namaTiket,
        'kategori': kategori,
        'harga': harga,
        'tanggal': tanggal,
        'tanggal_pembelian': DateTime.now(),
        'metode_pembayaran': paymentMethod,
        'status': 'completed'
      });
    } catch (e) {
      throw Exception('Failed to create purchase: $e');
    }
  }

  Stream<QuerySnapshot> getPurchaseHistory() {
    return purchasesCollection
        .orderBy('tanggal_pembelian', descending: true)
        .snapshots();
  }
}

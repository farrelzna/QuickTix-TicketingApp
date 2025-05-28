import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference ticket = FirebaseFirestore.instance.collection(
    'ticket',
  );

  Stream<QuerySnapshot> getTickets() {
    return ticket.snapshots();
  }
  Future<DocumentSnapshot> getTicketById(String id) {
    return ticket.doc(id).get();
  }
}
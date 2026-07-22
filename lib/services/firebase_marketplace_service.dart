import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_role.dart';

class MarketplaceProfessional {
  const MarketplaceProfessional({
    required this.uid,
    required this.name,
    required this.specialty,
    required this.priceCents,
    required this.isOnline,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String specialty;
  final int priceCents;
  final bool isOnline;
  final String? photoUrl;

  factory MarketplaceProfessional.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return MarketplaceProfessional(
      uid: document.id,
      name: data['name'] as String? ?? 'Prestadora REDGLOW',
      specialty: data['specialty'] as String? ?? 'Manicure',
      priceCents: data['priceCents'] as int? ?? 6000,
      isOnline: data['isOnline'] as bool? ?? false,
      photoUrl: data['photoUrl'] as String?,
    );
  }
}

class MarketplaceBooking {
  const MarketplaceBooking({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.clientName,
    required this.providerName,
    required this.status,
    required this.serviceName,
    required this.priceCents,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
    required this.clientRating,
    required this.providerRating,
  });

  final String id;
  final String clientId;
  final String providerId;
  final String clientName;
  final String providerName;
  final String status;
  final String serviceName;
  final int priceCents;
  final String address;
  final String paymentMethod;
  final DateTime createdAt;
  final int clientRating;
  final int providerRating;

  factory MarketplaceBooking.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final timestamp = data['createdAt'];
    return MarketplaceBooking(
      id: document.id,
      clientId: data['clientId'] as String? ?? '',
      providerId: data['providerId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? 'Cliente REDGLOW',
      providerName: data['providerName'] as String? ?? 'Prestadora REDGLOW',
      status: data['status'] as String? ?? 'requested',
      serviceName: data['serviceName'] as String? ?? 'Manicure e Pedicure',
      priceCents: data['priceCents'] as int? ?? 6000,
      address: data['address'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? 'Pix',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      clientRating: data['clientRating'] as int? ?? 0,
      providerRating: data['providerRating'] as int? ?? 0,
    );
  }
}

class FirebaseMarketplaceService {
  FirebaseMarketplaceService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Stream<List<MarketplaceProfessional>> watchProfessionals() {
    return _firestore.collection('professionals').snapshots().map((snapshot) {
      final professionals = snapshot.docs
          .map(MarketplaceProfessional.fromDocument)
          .toList()
        ..sort((a, b) {
          if (a.isOnline != b.isOnline) return a.isOnline ? -1 : 1;
          return a.name.compareTo(b.name);
        });
      return professionals;
    });
  }

  Future<void> ensureProfessionalProfile({
    required String uid,
    required String name,
  }) async {
    final reference = _firestore.collection('professionals').doc(uid);
    final current = await reference.get();
    if (current.exists) {
      await reference.update({
        'name': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await reference.set({
      'uid': uid,
      'name': name.trim(),
      'specialty': 'Manicure',
      'priceCents': 6000,
      'rating': 5.0,
      'services': 0,
      'isOnline': true,
      'photoUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setProviderOnline(String uid, bool isOnline) {
    return _firestore.collection('professionals').doc(uid).update({
      'isOnline': isOnline,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<MarketplaceBooking>> watchBookings({
    required String uid,
    required UserRole role,
  }) {
    final field = role == UserRole.client ? 'clientId' : 'providerId';
    return _firestore
        .collection('bookings')
        .where(field, isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs.map(MarketplaceBooking.fromDocument).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    });
  }

  Stream<String?> watchLastQuickMessage(String bookingId) {
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('quickMessages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty
            ? null
            : snapshot.docs.first.data()['body'] as String?);
  }

  Future<String> createBooking({
    required String clientId,
    required String providerId,
    required String clientName,
    required String providerName,
    required String paymentMethod,
  }) async {
    final reference = _firestore.collection('bookings').doc();
    await reference.set({
      'clientId': clientId,
      'providerId': providerId,
      'clientName': clientName,
      'providerName': providerName,
      'serviceName': 'Manicure e Pedicure',
      'priceCents': 6000,
      'address': 'R. Izabel A Redentora, 1000 — Centro, SJP',
      'paymentMethod': paymentMethod,
      'status': 'requested',
      'clientRating': 0,
      'providerRating': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return reference.id;
  }

  Future<void> updateBookingStatus(String bookingId, String status) {
    return _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendQuickMessage({
    required String bookingId,
    required String senderId,
    required String body,
  }) {
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('quickMessages')
        .add({
      'senderId': senderId,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitRating({
    required MarketplaceBooking booking,
    required String fromUid,
    required int score,
    required List<String> tags,
    required String comment,
  }) async {
    final toUid = fromUid == booking.clientId
        ? booking.providerId
        : booking.clientId;
    final ratingReference = _firestore
        .collection('ratings')
        .doc('${booking.id}_$fromUid');
    final batch = _firestore.batch();
    batch.set(ratingReference, {
      'bookingId': booking.id,
      'fromUid': fromUid,
      'toUid': toUid,
      'score': score,
      'tags': tags,
      'comment': comment.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (fromUid == booking.clientId) {
      batch.update(_firestore.collection('bookings').doc(booking.id), {
        'status': 'reviewed',
        'clientRating': score,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      batch.update(_firestore.collection('bookings').doc(booking.id), {
        'providerRating': score,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> requestAccountDeletion(String uid) {
    return _firestore.collection('accountDeletionRequests').doc(uid).set({
      'uid': uid,
      'status': 'requested',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }
}

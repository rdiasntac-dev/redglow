import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/service_catalog.dart';
import '../models/user_role.dart';

class MarketplaceProfessional {
  const MarketplaceProfessional({
    required this.uid,
    required this.name,
    required this.specialty,
    required this.specialties,
    required this.priceCents,
    required this.rating,
    required this.services,
    required this.isOnline,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
    this.professionalIdStatus = 'pending',
  });

  final String uid;
  final String name;
  final String specialty;
  final List<String> specialties;
  final int priceCents;
  final double rating;
  final List<String> services;
  final bool isOnline;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final DateTime? locationUpdatedAt;
  final String professionalIdStatus;

  factory MarketplaceProfessional.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final specialty = RedGlowServiceCatalog.normalizeLabel(
      data['specialty'] as String?,
    );
    final rawSpecialties = data['specialties'];
    final specialties = RedGlowServiceCatalog.normalizeLabels(
      rawSpecialties is List
          ? rawSpecialties.whereType<String>()
          : <String>[specialty],
    );
    final effectiveSpecialties =
        specialties.isEmpty ? <String>[specialty] : specialties;
    final category = RedGlowServiceCatalog.byLabel(specialty);
    final rawServices = data['services'];
    final services = RedGlowServiceCatalog.validServicesForCategories(
      effectiveSpecialties,
      rawServices is List ? rawServices.whereType<String>() : const <String>[],
    );
    final location = data['location'];
    final locationData =
        location is Map ? Map<String, dynamic>.from(location) : null;
    final locationTimestamp = locationData?['updatedAt'];
    return MarketplaceProfessional(
      uid: document.id,
      name: data['name'] as String? ?? 'Prestadora REDGLOW',
      specialty: specialty,
      specialties: effectiveSpecialties,
      priceCents:
          data['priceCents'] as int? ?? category.recommendedHomeCents,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      services: services,
      isOnline: data['isOnline'] as bool? ?? false,
      photoUrl: data['photoUrl'] as String?,
      latitude: (locationData?['latitude'] as num?)?.toDouble(),
      longitude: (locationData?['longitude'] as num?)?.toDouble(),
      locationUpdatedAt:
          locationTimestamp is Timestamp ? locationTimestamp.toDate() : null,
      professionalIdStatus:
          data['professionalIdStatus'] as String? ?? 'pending',
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
    required this.updatedAt,
    required this.clientRating,
    required this.providerRating,
    required this.cancellationReason,
    required this.cancelledBy,
    required this.simulatedFeeCents,
    this.clientLatitude,
    this.clientLongitude,
    this.providerLatitude,
    this.providerLongitude,
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
  final DateTime updatedAt;
  final int clientRating;
  final int providerRating;
  final String cancellationReason;
  final String cancelledBy;
  final int simulatedFeeCents;
  final double? clientLatitude;
  final double? clientLongitude;
  final double? providerLatitude;
  final double? providerLongitude;

  factory MarketplaceBooking.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final createdTimestamp = data['createdAt'];
    final updatedTimestamp = data['updatedAt'];
    final clientLocation = data['clientLocation'];
    final providerLocation = data['providerLocation'];
    final clientLocationData = clientLocation is Map
        ? Map<String, dynamic>.from(clientLocation)
        : null;
    final providerLocationData = providerLocation is Map
        ? Map<String, dynamic>.from(providerLocation)
        : null;
    final updatedAt = updatedTimestamp is Timestamp
        ? updatedTimestamp.toDate()
        : DateTime.now();
    return MarketplaceBooking(
      id: document.id,
      clientId: data['clientId'] as String? ?? '',
      providerId: data['providerId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? 'Cliente REDGLOW',
      providerName: data['providerName'] as String? ?? 'Prestadora REDGLOW',
      status: data['status'] as String? ?? 'requested',
      serviceName: data['serviceName'] as String? ?? 'Manicure',
      priceCents: data['priceCents'] as int? ?? 4500,
      address: data['address'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? 'Pix',
      createdAt:
          createdTimestamp is Timestamp ? createdTimestamp.toDate() : updatedAt,
      updatedAt: updatedAt,
      clientRating: data['clientRating'] as int? ?? 0,
      providerRating: data['providerRating'] as int? ?? 0,
      cancellationReason: data['cancellationReason'] as String? ?? '',
      cancelledBy: data['cancelledBy'] as String? ?? '',
      simulatedFeeCents: data['simulatedFeeCents'] as int? ?? 0,
      clientLatitude:
          (clientLocationData?['latitude'] as num?)?.toDouble(),
      clientLongitude:
          (clientLocationData?['longitude'] as num?)?.toDouble(),
      providerLatitude:
          (providerLocationData?['latitude'] as num?)?.toDouble(),
      providerLongitude:
          (providerLocationData?['longitude'] as num?)?.toDouble(),
    );
  }
}

class MarketplaceRating {
  const MarketplaceRating({
    required this.fromUid,
    required this.toUid,
    required this.score,
    required this.tags,
    required this.comment,
  });

  final String fromUid;
  final String toUid;
  final int score;
  final List<String> tags;
  final String comment;

  factory MarketplaceRating.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return MarketplaceRating(
      fromUid: data['fromUid'] as String? ?? '',
      toUid: data['toUid'] as String? ?? '',
      score: data['score'] as int? ?? 0,
      tags: (data['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      comment: data['comment'] as String? ?? '',
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
    final defaultCategory = RedGlowServiceCatalog.categories.first;
    if (current.exists) {
      final data = current.data() ?? const <String, dynamic>{};
      final specialty = RedGlowServiceCatalog.normalizeLabel(
        data['specialty'] as String?,
      );
      final category = RedGlowServiceCatalog.byLabel(specialty);
      final rawSpecialties = data['specialties'];
      final specialties = RedGlowServiceCatalog.normalizeLabels(
        rawSpecialties is List
            ? rawSpecialties.whereType<String>()
            : <String>[specialty],
      );
      final effectiveSpecialties =
          specialties.isEmpty ? <String>[specialty] : specialties;
      final rawServices = data['services'];
      final services = RedGlowServiceCatalog.validServicesForCategories(
        effectiveSpecialties,
        rawServices is List ? rawServices.whereType<String>() : category.services,
      );
      await reference.update({
        'name': name.trim(),
        'specialty': specialty,
        'specialties': effectiveSpecialties,
        'priceCents': data['priceCents'] as int? ?? category.recommendedHomeCents,
        'services': services.isEmpty ? category.services : services,
        'professionalIdStatus':
            data['professionalIdStatus'] as String? ?? 'pending',
        if (data.containsKey('location'))
          'location': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await reference.set({
      'uid': uid,
      'name': name.trim(),
      'specialty': defaultCategory.label,
      'specialties': [defaultCategory.label],
      'priceCents': defaultCategory.recommendedHomeCents,
      'rating': 0.0,
      'services': defaultCategory.services,
      'isOnline': true,
      'photoUrl': null,
      'professionalIdStatus': 'pending',
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

  Future<void> updateProfilePhoto({
    required String uid,
    required UserRole role,
    required String photoUrl,
  }) async {
    final cleanUrl = photoUrl.trim();
    final batch = _firestore.batch();
    batch.update(_firestore.collection('users').doc(uid), {
      'photoUrl': cleanUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (role == UserRole.provider) {
      batch.update(_firestore.collection('professionals').doc(uid), {
        'photoUrl': cleanUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    await _auth.currentUser?.updatePhotoURL(cleanUrl);
  }

  Future<void> updateCurrentLocation({
    required String uid,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    final location = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('users').doc(uid).update({
      'location': location,
      'locationPermission': 'granted',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProviderServices({
    required String uid,
    required List<String> specialties,
    required List<String> services,
  }) {
    final normalizedSpecialties =
        RedGlowServiceCatalog.normalizeLabels(specialties);
    final validServices = RedGlowServiceCatalog.validServicesForCategories(
      normalizedSpecialties,
      services,
    ).toList()
      ..sort();
    if (normalizedSpecialties.isEmpty || validServices.isEmpty) {
      throw ArgumentError.value(
        services,
        'services',
        'Selecione pelo menos um nicho e um serviço válido.',
      );
    }
    return _firestore.collection('professionals').doc(uid).update({
      'specialty': normalizedSpecialties.first,
      'specialties': normalizedSpecialties,
      'services': validServices,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProfile({
    required String uid,
    required UserRole role,
    required String name,
    required String phone,
    String? specialty,
    int? priceCents,
  }) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('users').doc(uid), {
      'name': name.trim(),
      'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (role == UserRole.provider) {
      final normalizedSpecialty =
          RedGlowServiceCatalog.normalizeLabel(specialty);
      final category = RedGlowServiceCatalog.byLabel(normalizedSpecialty);
      final professionalReference =
          _firestore.collection('professionals').doc(uid);
      final currentProfessional = await professionalReference.get();
      final currentData =
          currentProfessional.data() ?? const <String, dynamic>{};
      final currentSpecialty = RedGlowServiceCatalog.normalizeLabel(
        currentData['specialty'] as String?,
      );
      final rawSpecialties = currentData['specialties'];
      final currentSpecialties = RedGlowServiceCatalog.normalizeLabels(
        rawSpecialties is List
            ? rawSpecialties.whereType<String>()
            : <String>[currentSpecialty],
      );
      final rawServices = currentData['services'];
      final effectiveSpecialties = currentSpecialties.contains(
        normalizedSpecialty,
      )
          ? currentSpecialties
          : <String>[normalizedSpecialty, ...currentSpecialties];
      final currentServices = RedGlowServiceCatalog.validServicesForCategories(
        effectiveSpecialties,
        rawServices is List ? rawServices.whereType<String>() : const <String>[],
      );
      final professionalUpdate = <String, dynamic>{
        'name': name.trim(),
        'specialty': normalizedSpecialty,
        'specialties': effectiveSpecialties,
        'priceCents': priceCents ?? category.recommendedHomeCents,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (currentSpecialty != normalizedSpecialty ||
          rawSpecialties is! List ||
          rawServices is! List ||
          currentServices.length != rawServices.length ||
          currentServices.isEmpty) {
        professionalUpdate['services'] =
            currentServices.isEmpty ? category.services : currentServices;
      }
      batch.update(professionalReference, professionalUpdate);
    }
    await batch.commit();
    await _auth.currentUser?.updateDisplayName(name.trim());
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

  Stream<MarketplaceRating?> watchRating({
    required String bookingId,
    required String fromUid,
  }) {
    return _firestore
        .collection('ratings')
        .doc('${bookingId}_$fromUid')
        .snapshots()
        .map((document) => document.exists
            ? MarketplaceRating.fromDocument(document)
            : null);
  }

  Future<String> createBooking({
    required String clientId,
    required String providerId,
    required String clientName,
    required String providerName,
    required String serviceName,
    required String paymentMethod,
    double? clientLatitude,
    double? clientLongitude,
  }) async {
    final professionalReference =
        _firestore.collection('professionals').doc(providerId);
    final professionalSnapshot = await professionalReference.get();
    final professional = professionalSnapshot.data();
    if (!professionalSnapshot.exists || professional == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'A profissional selecionada não foi encontrada.',
      );
    }
    if (professional['isOnline'] != true) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'failed-precondition',
        message: 'A profissional selecionada não está disponível.',
      );
    }

    final specialty = RedGlowServiceCatalog.normalizeLabel(
      professional['specialty'] as String?,
    );
    final rawSpecialties = professional['specialties'];
    final specialties = RedGlowServiceCatalog.normalizeLabels(
      rawSpecialties is List
          ? rawSpecialties.whereType<String>()
          : <String>[specialty],
    );
    final effectiveSpecialties =
        specialties.isEmpty ? <String>[specialty] : specialties;
    final category = RedGlowServiceCatalog.byLabel(specialty);
    final cleanServiceName = serviceName.trim();
    final rawServices = professional['services'];
    final availableServices = RedGlowServiceCatalog.validServicesForCategories(
      effectiveSpecialties,
      rawServices is List ? rawServices.whereType<String>() : const <String>[],
    );
    if (!availableServices.contains(cleanServiceName)) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'failed-precondition',
        message: 'O serviço selecionado não está disponível neste perfil.',
      );
    }
    final currentProviderName =
        (professional['name'] as String?)?.trim().isNotEmpty == true
            ? (professional['name'] as String).trim()
            : providerName.trim();
    final currentPrice =
        professional['priceCents'] as int? ?? category.recommendedHomeCents;
    final reference = _firestore.collection('bookings').doc();
    await reference.set({
      'clientId': clientId,
      'providerId': providerId,
      'clientName': clientName,
      'providerName': currentProviderName,
      'serviceName': cleanServiceName,
      'priceCents': currentPrice,
      'address': 'R. Izabel A Redentora, 1000 — Centro, SJP',
      'clientLocation': clientLatitude != null && clientLongitude != null
          ? {
              'latitude': clientLatitude,
              'longitude': clientLongitude,
            }
          : null,
      'providerLocation': null,
      'paymentMethod': paymentMethod,
      'status': 'requested',
      'clientRating': 0,
      'providerRating': 0,
      'cancellationReason': '',
      'cancelledBy': '',
      'simulatedFeeCents': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return reference.id;
  }

  Future<void> updateBookingStatus(
    String bookingId,
    String status, {
    double? providerLatitude,
    double? providerLongitude,
  }) {
    return _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      if (providerLatitude != null && providerLongitude != null)
        'providerLocation': {
          'latitude': providerLatitude,
          'longitude': providerLongitude,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelBooking({
    required String bookingId,
    required String cancelledBy,
    required String reason,
  }) {
    return _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancellationReason': reason.trim(),
      'cancelledBy': cancelledBy,
      'simulatedFeeCents': 0,
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
    final bookingReference =
        _firestore.collection('bookings').doc(booking.id);
    final ratingReference = _firestore
        .collection('ratings')
        .doc('${booking.id}_$fromUid');
    await _firestore.runTransaction((transaction) async {
      final liveSnapshot = await transaction.get(bookingReference);
      final liveData = liveSnapshot.data();
      if (!liveSnapshot.exists || liveData == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'O atendimento não foi encontrado.',
        );
      }
      final clientId = liveData['clientId'] as String? ?? '';
      final providerId = liveData['providerId'] as String? ?? '';
      if (fromUid != clientId && fromUid != providerId) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Esta conta não participa do atendimento.',
        );
      }
      final status = liveData['status'] as String? ?? '';
      if (status != 'completed' && status != 'reviewed') {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'failed-precondition',
          message: 'A avaliação é liberada somente após a conclusão.',
        );
      }
      final fromClient = fromUid == clientId;
      final ownRating =
          liveData[fromClient ? 'clientRating' : 'providerRating'] as int? ?? 0;
      if (ownRating > 0) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-exists',
          message: 'Sua avaliação já foi registrada.',
        );
      }
      final otherRating =
          liveData[fromClient ? 'providerRating' : 'clientRating'] as int? ?? 0;
      final toUid = fromClient ? providerId : clientId;
      transaction.set(ratingReference, {
        'bookingId': booking.id,
        'fromUid': fromUid,
        'toUid': toUid,
        'score': score,
        'tags': tags,
        'comment': comment.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(bookingReference, {
        if (fromClient) 'clientRating': score else 'providerRating': score,
        'status': otherRating > 0 ? 'reviewed' : 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> requestAccountDeletion(String uid) {
    return _firestore.collection('accountDeletionRequests').doc(uid).set({
      'uid': uid,
      'status': 'requested',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitReport({
    required String reporterId,
    required String bookingId,
    required String category,
    required String description,
  }) {
    return _firestore.collection('reports').add({
      'reporterId': reporterId,
      'bookingId': bookingId,
      'category': category,
      'description': description.trim(),
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

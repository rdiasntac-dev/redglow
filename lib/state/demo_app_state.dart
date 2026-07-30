import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/service_catalog.dart';
import '../models/user_role.dart';
import '../services/device_location_service.dart';
import '../services/firebase_marketplace_service.dart';

enum DemoBookingStatus {
  idle,
  requested,
  accepted,
  onTheWay,
  inProgress,
  completed,
  reviewed,
  cancelled,
}

extension DemoBookingStatusLabel on DemoBookingStatus {
  String get label => switch (this) {
        DemoBookingStatus.idle => 'Nenhum atendimento ativo',
        DemoBookingStatus.requested => 'Aguardando aceite da prestadora',
        DemoBookingStatus.accepted => 'Pedido aceito',
        DemoBookingStatus.onTheWay => 'Prestadora a caminho',
        DemoBookingStatus.inProgress => 'Atendimento em andamento',
        DemoBookingStatus.completed => 'Serviço concluído',
        DemoBookingStatus.reviewed => 'Avaliação enviada',
        DemoBookingStatus.cancelled => 'Pedido cancelado',
      };
}

class DemoAppState extends ChangeNotifier {
  static const pointsRedemptionCost = 3000;

  FirebaseMarketplaceService? _marketplaceService;
  DeviceLocationService? _locationService;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSubscription;
  StreamSubscription<List<MarketplaceProfessional>>? _professionalsSubscription;
  StreamSubscription<List<MarketplaceBooking>>? _bookingsSubscription;
  StreamSubscription<String?>? _quickMessageSubscription;
  StreamSubscription<MarketplaceRating?>? _clientRatingSubscription;
  StreamSubscription<MarketplaceRating?>? _providerRatingSubscription;
  int _sessionVersion = 0;
  bool _disposed = false;

  FirebaseMarketplaceService get _marketplace =>
      _marketplaceService ??= FirebaseMarketplaceService();
  DeviceLocationService get _location =>
      _locationService ??= const DeviceLocationService();

  UserRole activeRole = UserRole.client;
  bool isDemoSession = true;
  String? accountName;
  String? accountEmail;
  String? accountPhone;
  String? accountPhotoUrl;
  double? accountLatitude;
  double? accountLongitude;
  double? locationAccuracy;
  DateTime? locationUpdatedAt;
  bool locationLoading = false;
  String? locationError;
  String demoProviderSpecialty = 'Manicure';
  List<String> demoProviderSpecialties = const ['Manicure', 'Pedicure'];
  int demoProviderPriceCents = 6000;
  List<String> demoProviderServices = const [
    'Manicure tradicional',
    'Esmaltação em gel',
    'Spa das mãos',
    'Pedicure tradicional',
    'Spa dos pés',
    'Manicure e pedicure',
  ];
  String? currentUserId;
  MarketplaceProfessional? selectedProfessional;
  String? selectedServiceName;
  MarketplaceBooking? currentBooking;
  List<MarketplaceBooking> bookingHistory = [];
  bool backendLoading = false;
  String? backendError;
  bool providerOnline = true;
  DemoBookingStatus bookingStatus = DemoBookingStatus.idle;
  int points = 2480;
  bool clientIdentityVerified = false;
  bool providerIdentityVerified = false;
  bool professionalPlanActive = false;
  bool isAdmin = false;
  String? lastQuickMessage;
  int clientToProviderRating = 0;
  int providerToClientRating = 0;
  List<String> clientToProviderTags = [];
  List<String> providerToClientTags = [];
  String clientToProviderComment = '';
  String providerToClientComment = '';
  String lastCancellationReason = '';
  int simulatedCancellationFeeCents = 0;

  String get providerName =>
      currentBooking?.providerName ??
      selectedProfessional?.name ??
      'Lari (Manicure)';

  String get clientName => currentBooking?.clientName ?? 'Cliente REDGLOW';

  bool get hasRealProvider =>
      isDemoSession || selectedProfessional?.isOnline == true;

  String get providerSpecialty =>
      selectedProfessional?.specialty ?? demoProviderSpecialty;

  List<String> get providerSpecialties =>
      selectedProfessional?.specialties ?? demoProviderSpecialties;

  int get providerPriceCents =>
      selectedProfessional?.priceCents ?? demoProviderPriceCents;

  List<String> get providerServices =>
      selectedProfessional?.services ?? demoProviderServices;

  String get professionalIdStatus =>
      isDemoSession
          ? providerIdentityVerified
              ? 'verified'
              : 'pending'
          : selectedProfessional?.professionalIdStatus ?? 'pending';

  bool get professionalIdVerified =>
      professionalIdStatus == 'verified';

  String get profilePhotoUrl {
    final professionalPhoto = selectedProfessional?.photoUrl?.trim();
    if (activeRole == UserRole.provider &&
        professionalPhoto != null &&
        professionalPhoto.isNotEmpty) {
      return professionalPhoto;
    }
    return accountPhotoUrl?.trim() ?? '';
  }

  bool get hasCurrentLocation =>
      accountLatitude != null && accountLongitude != null;

  String get locationSummary {
    if (locationLoading) return 'Obtendo sua localização...';
    if (hasCurrentLocation) {
      return 'Localização atual confirmada · precisão de ${locationAccuracy?.round() ?? 0} m';
    }
    return locationError ?? 'Toque para permitir a localização durante o uso.';
  }

  List<MarketplaceBooking> get visibleActiveBookings => bookingHistory
      .where((booking) => {
            'requested',
            'accepted',
            'onTheWay',
            'inProgress',
          }.contains(booking.status))
      .toList(growable: false);

  List<MarketplaceBooking> get pendingRatings => bookingHistory
      .where(
        (booking) =>
            booking.status == 'completed' &&
            (activeRole == UserRole.client
                ? booking.clientRating == 0
                : booking.providerRating == 0),
      )
      .toList(growable: false);

  String get selectedService =>
      selectedServiceName ??
      (providerServices.isNotEmpty ? providerServices.first : providerSpecialty);

  bool get hasActiveBooking => !{
        DemoBookingStatus.idle,
        DemoBookingStatus.reviewed,
        DemoBookingStatus.cancelled,
      }.contains(bookingStatus);

  bool get identityVerified => activeRole == UserRole.client
      ? clientIdentityVerified
      : providerIdentityVerified;

  void selectRole(UserRole role) {
    activeRole = role;
    notifyListeners();
  }

  void startSession({
    required UserRole role,
    required bool demo,
    String? name,
  }) {
    final previousSessionWasDemo = isDemoSession;
    _sessionVersion++;
    _cancelRealtimeSubscriptions();
    activeRole = role;
    isDemoSession = demo;
    accountName = name;
    backendError = null;
    backendLoading = !demo;
    if (demo) {
      currentUserId = null;
      accountEmail = null;
      accountPhone = null;
      accountPhotoUrl = null;
      accountLatitude = null;
      accountLongitude = null;
      locationAccuracy = null;
      locationUpdatedAt = null;
      locationError = null;
      selectedProfessional = null;
      selectedServiceName = null;
      currentBooking = null;
      bookingHistory = [];
      isAdmin = false;
      if (!previousSessionWasDemo) {
        points = 2480;
        bookingStatus = DemoBookingStatus.idle;
        clientIdentityVerified = false;
        providerIdentityVerified = false;
        professionalPlanActive = false;
        clientToProviderRating = 0;
        providerToClientRating = 0;
        _clearRatingDetails();
        lastQuickMessage = null;
        lastCancellationReason = '';
        simulatedCancellationFeeCents = 0;
      }
    } else {
      points = 0;
      bookingStatus = DemoBookingStatus.idle;
      clientToProviderRating = 0;
      providerToClientRating = 0;
      _clearRatingDetails();
      lastQuickMessage = null;
      lastCancellationReason = '';
      simulatedCancellationFeeCents = 0;
      selectedProfessional = null;
      selectedServiceName = null;
      currentBooking = null;
      bookingHistory = [];
      isAdmin = false;
      accountPhotoUrl = null;
      accountLatitude = null;
      accountLongitude = null;
      locationAccuracy = null;
      locationUpdatedAt = null;
      locationError = null;
      _connectRealSession(_sessionVersion);
    }
    notifyListeners();
  }

  Future<bool> requestBooking({String paymentMethod = 'Pix'}) async {
    if (isDemoSession) {
      bookingStatus = DemoBookingStatus.requested;
      lastQuickMessage = null;
      lastCancellationReason = '';
      simulatedCancellationFeeCents = 0;
      clientToProviderRating = 0;
      providerToClientRating = 0;
      _clearRatingDetails();
      notifyListeners();
      return true;
    }

    final userId = currentUserId;
    final professional = selectedProfessional;
    if (userId == null || professional == null || !professional.isOnline) {
      _setBackendError(
        'Nenhuma prestadora real está online. Cadastre ou conecte uma conta de prestadora para testar o ciclo.',
      );
      return false;
    }

    return _runBackendAction(() async {
      await _marketplace.createBooking(
        clientId: userId,
        providerId: professional.uid,
        clientName: accountName ?? 'Cliente REDGLOW',
        providerName: professional.name,
        serviceName: selectedService,
        paymentMethod: paymentMethod,
        clientLatitude: accountLatitude,
        clientLongitude: accountLongitude,
      );
    });
  }

  void selectProfessional(
    MarketplaceProfessional professional, {
    String? serviceName,
  }) {
    selectedProfessional = professional;
    final requestedService = serviceName?.trim();
    selectedServiceName = requestedService != null &&
            professional.services.contains(requestedService)
        ? requestedService
        : professional.services.isNotEmpty
            ? professional.services.first
            : null;
    notifyListeners();
  }

  void selectBooking(MarketplaceBooking booking) {
    currentBooking = booking;
    bookingStatus = _statusFromBackend(booking.status);
    clientToProviderRating = booking.clientRating;
    providerToClientRating = booking.providerRating;
    lastCancellationReason = booking.cancellationReason;
    simulatedCancellationFeeCents = booking.simulatedFeeCents;
    if (!isDemoSession) {
      _watchBookingDetails(_sessionVersion, booking);
    }
    notifyListeners();
  }

  Future<bool> acceptBooking() {
    return _changeBookingStatus(DemoBookingStatus.accepted, 'accepted');
  }

  Future<bool> startTrip() async {
    if (!isDemoSession && activeRole == UserRole.provider) {
      await refreshLocation(showPermissionError: false);
    }
    return _changeBookingStatus(DemoBookingStatus.onTheWay, 'onTheWay');
  }

  Future<bool> startService() {
    return _changeBookingStatus(DemoBookingStatus.inProgress, 'inProgress');
  }

  Future<bool> completeService() {
    return _changeBookingStatus(DemoBookingStatus.completed, 'completed');
  }

  Future<bool> cancelBooking({String reason = 'Outro motivo'}) async {
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) {
      _setBackendError('Selecione o motivo do cancelamento.');
      return false;
    }
    if (isDemoSession) {
      lastCancellationReason = cleanReason;
      simulatedCancellationFeeCents = 0;
      bookingStatus = DemoBookingStatus.cancelled;
      notifyListeners();
      return true;
    }
    final userId = currentUserId;
    final bookingId = currentBooking?.id;
    if (userId == null || bookingId == null) {
      _setBackendError('Nenhum atendimento foi encontrado para cancelar.');
      return false;
    }
    return _runBackendAction(
      () => _marketplace.cancelBooking(
        bookingId: bookingId,
        cancelledBy: userId,
        reason: cleanReason,
      ),
    );
  }

  Future<bool> sendQuickMessage(String message) async {
    if (isDemoSession) {
      lastQuickMessage = message;
      notifyListeners();
      return true;
    }
    final userId = currentUserId;
    final bookingId = currentBooking?.id;
    if (userId == null || bookingId == null) {
      _setBackendError('Não há atendimento ativo para enviar a mensagem.');
      return false;
    }
    return _runBackendAction(() => _marketplace.sendQuickMessage(
          bookingId: bookingId,
          senderId: userId,
          body: message,
        ));
  }

  Future<bool> submitRating(
    int rating, {
    bool asProvider = false,
    List<String> tags = const [],
    String comment = '',
    String? bookingId,
  }) async {
    if (isDemoSession) {
      if (asProvider) {
        providerToClientRating = rating;
        providerToClientTags = List.of(tags);
        providerToClientComment = comment.trim();
      } else {
        if (clientToProviderRating == 0) points += 60;
        clientToProviderRating = rating;
        clientToProviderTags = List.of(tags);
        clientToProviderComment = comment.trim();
        bookingStatus = DemoBookingStatus.reviewed;
      }
      notifyListeners();
      return true;
    }

    final userId = currentUserId;
    MarketplaceBooking? booking = currentBooking;
    if (bookingId != null) {
      for (final candidate in bookingHistory) {
        if (candidate.id == bookingId) {
          booking = candidate;
          break;
        }
      }
    }
    if (userId == null || booking == null) {
      _setBackendError('O atendimento não foi encontrado para registrar a avaliação.');
      return false;
    }
    final selectedBooking = booking;
    return _runBackendAction(() => _marketplace.submitRating(
          booking: selectedBooking,
          fromUid: userId,
          score: rating,
          tags: tags,
          comment: comment,
        ));
  }

  Future<bool> setProviderOnline(bool value) async {
    providerOnline = value;
    notifyListeners();
    if (isDemoSession) return true;
    final userId = currentUserId;
    if (userId == null) return false;
    if (value) {
      await refreshLocation(showPermissionError: false);
    }
    final succeeded = await _runBackendAction(
      () => _marketplace.setProviderOnline(userId, value),
    );
    if (!succeeded) {
      providerOnline = !value;
      notifyListeners();
    }
    return succeeded;
  }

  Future<bool> refreshLocation({bool showPermissionError = true}) async {
    if (locationLoading) return false;
    locationLoading = true;
    locationError = null;
    notifyListeners();
    try {
      if (isDemoSession) {
        accountLatitude = -25.5350;
        accountLongitude = -49.2058;
        locationAccuracy = 12;
        locationUpdatedAt = DateTime.now();
        return true;
      }
      final userId = currentUserId;
      if (userId == null) {
        locationError = 'A sessão expirou. Entre novamente.';
        return false;
      }
      final result = await _location.current();
      accountLatitude = result.latitude;
      accountLongitude = result.longitude;
      locationAccuracy = result.accuracy;
      locationUpdatedAt = result.capturedAt;
      await _marketplace.updateCurrentLocation(
        uid: userId,
        latitude: result.latitude,
        longitude: result.longitude,
        accuracy: result.accuracy,
      );
      return true;
    } on LocationPermissionException catch (error) {
      locationError = error.message;
      if (showPermissionError) {
        _setBackendError(error.message);
      }
      return false;
    } on FirebaseException catch (error) {
      locationError = _firebaseActionMessage(error);
      if (showPermissionError) _setBackendError(locationError!);
      return false;
    } catch (_) {
      locationError = 'Não foi possível obter sua localização agora.';
      if (showPermissionError) _setBackendError(locationError!);
      return false;
    } finally {
      locationLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> updateProfilePhoto(String photoUrl) async {
    final cleanUrl = photoUrl.trim();
    if (cleanUrl.isEmpty) {
      _setBackendError('Selecione uma foto válida.');
      return false;
    }
    if (isDemoSession) {
      accountPhotoUrl = cleanUrl;
      notifyListeners();
      return true;
    }
    final userId = currentUserId;
    if (userId == null) {
      _setBackendError('A sessão expirou. Entre novamente.');
      return false;
    }
    final succeeded = await _runBackendAction(
      () => _marketplace.updateProfilePhoto(
        uid: userId,
        role: activeRole,
        photoUrl: cleanUrl,
      ),
    );
    if (succeeded) {
      accountPhotoUrl = cleanUrl;
      notifyListeners();
    }
    return succeeded;
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? specialty,
    int? priceCents,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    if (cleanName.length < 2) {
      _setBackendError('Informe um nome válido.');
      return false;
    }
    if (cleanPhone.replaceAll(RegExp(r'\D'), '').length < 10) {
      _setBackendError('Informe um celular válido.');
      return false;
    }
    if (activeRole == UserRole.provider &&
        (priceCents == null || priceCents < 1000)) {
      _setBackendError('Informe um valor de serviço válido.');
      return false;
    }

    if (isDemoSession) {
      accountName = cleanName;
      accountPhone = cleanPhone;
      if (activeRole == UserRole.provider) {
        final previousSpecialty = demoProviderSpecialty;
        demoProviderSpecialty = RedGlowServiceCatalog.normalizeLabel(
          specialty ?? demoProviderSpecialty,
        );
        demoProviderPriceCents = priceCents ?? demoProviderPriceCents;
        if (previousSpecialty != demoProviderSpecialty) {
          demoProviderServices = List.of(
            RedGlowServiceCatalog.byLabel(demoProviderSpecialty).services,
          );
        }
      }
      notifyListeners();
      return true;
    }

    final userId = currentUserId;
    if (userId == null) {
      _setBackendError('A sessão expirou. Entre novamente.');
      return false;
    }
    return _runBackendAction(
      () => _marketplace.updateProfile(
        uid: userId,
        role: activeRole,
        name: cleanName,
        phone: cleanPhone,
        specialty: specialty,
        priceCents: priceCents,
      ),
    );
  }

  Future<bool> updateProviderServices({
    required List<String> specialties,
    required List<String> services,
  }) async {
    final normalizedSpecialties =
        RedGlowServiceCatalog.normalizeLabels(specialties);
    final validServices = RedGlowServiceCatalog.validServicesForCategories(
      normalizedSpecialties,
      services,
    ).toList()
      ..sort();
    if (normalizedSpecialties.isEmpty || validServices.isEmpty) {
      _setBackendError('Selecione pelo menos um nicho e um serviço válido.');
      return false;
    }
    if (isDemoSession) {
      demoProviderSpecialty = normalizedSpecialties.first;
      demoProviderSpecialties = List.unmodifiable(normalizedSpecialties);
      demoProviderServices = List.unmodifiable(validServices);
      selectedServiceName = validServices.first;
      notifyListeners();
      return true;
    }
    final userId = currentUserId;
    if (userId == null) {
      _setBackendError('A sessão expirou. Entre novamente.');
      return false;
    }
    return _runBackendAction(
      () => _marketplace.updateProviderServices(
        uid: userId,
        specialties: normalizedSpecialties,
        services: validServices,
      ),
    );
  }

  Future<bool> requestAccountDeletion() async {
    if (isDemoSession) return true;
    final userId = currentUserId;
    if (userId == null) {
      _setBackendError('A sessão expirou. Entre novamente para solicitar a exclusão.');
      return false;
    }
    return _runBackendAction(
      () => _marketplace.requestAccountDeletion(userId),
    );
  }

  Future<bool> submitReport({
    required String category,
    required String description,
  }) async {
    final cleanDescription = description.trim();
    if (cleanDescription.length < 10) {
      _setBackendError('Descreva a situação com pelo menos 10 caracteres.');
      return false;
    }
    if (isDemoSession) return true;
    final userId = currentUserId;
    if (userId == null) {
      _setBackendError('A sessão expirou. Entre novamente.');
      return false;
    }
    return _runBackendAction(
      () => _marketplace.submitReport(
        reporterId: userId,
        bookingId: currentBooking?.id ?? '',
        category: category,
        description: cleanDescription,
      ),
    );
  }

  void markIdentityVerified() {
    if (activeRole == UserRole.client) {
      clientIdentityVerified = true;
    } else {
      providerIdentityVerified = true;
    }
    notifyListeners();
  }

  void activateProfessionalPlan() {
    professionalPlanActive = true;
    notifyListeners();
  }

  bool redeemPoints() {
    if (!isDemoSession || points < pointsRedemptionCost) return false;
    points -= pointsRedemptionCost;
    notifyListeners();
    return true;
  }

  void resetBooking() {
    bookingStatus = DemoBookingStatus.idle;
    lastQuickMessage = null;
    lastCancellationReason = '';
    simulatedCancellationFeeCents = 0;
    clientToProviderRating = 0;
    providerToClientRating = 0;
    _clearRatingDetails();
    notifyListeners();
  }

  void _connectRealSession(int version) {
    if (Firebase.apps.isEmpty) {
      backendLoading = false;
      return;
    }
    final user = _marketplace.currentUser;
    if (user == null) {
      backendLoading = false;
      _setBackendError('A sessão do Firebase expirou. Entre novamente.');
      return;
    }
    currentUserId = user.uid;

    _profileSubscription = _marketplace.watchUser(user.uid).listen(
      (snapshot) {
        if (!_isCurrentSession(version)) return;
        final data = snapshot.data();
        accountName = data?['name'] as String? ?? user.displayName;
        accountEmail = data?['email'] as String? ?? user.email;
        accountPhone = data?['phone'] as String?;
        accountPhotoUrl =
            data?['photoUrl'] as String? ?? user.photoURL ?? accountPhotoUrl;
        final rawLocation = data?['location'];
        final location =
            rawLocation is Map ? Map<String, dynamic>.from(rawLocation) : null;
        accountLatitude =
            (location?['latitude'] as num?)?.toDouble() ?? accountLatitude;
        accountLongitude =
            (location?['longitude'] as num?)?.toDouble() ?? accountLongitude;
        locationAccuracy =
            (location?['accuracy'] as num?)?.toDouble() ?? locationAccuracy;
        final updatedAt = location?['updatedAt'];
        if (updatedAt is Timestamp) locationUpdatedAt = updatedAt.toDate();
        isAdmin = data?['isAdmin'] == true;
        points = data?['points'] as int? ?? 0;
        final verified = data?['identityStatus'] == 'verified';
        if (activeRole == UserRole.client) {
          clientIdentityVerified = verified;
        } else {
          providerIdentityVerified = verified;
        }
        backendLoading = false;
        notifyListeners();
      },
      onError: (Object error) => _handleRealtimeError(version, error),
    );

    _professionalsSubscription = _marketplace.watchProfessionals().listen(
      (professionals) {
        if (!_isCurrentSession(version)) return;
        if (activeRole == UserRole.client) {
          selectedProfessional = _preserveSelectedProfessional(
            professionals,
            selectedProfessional,
          );
          if (selectedProfessional != null &&
              !selectedProfessional!.services.contains(selectedServiceName)) {
            selectedServiceName = selectedProfessional!.services.isNotEmpty
                ? selectedProfessional!.services.first
                : null;
          }
        } else {
          for (final professional in professionals) {
            if (professional.uid == user.uid) {
              selectedProfessional = professional;
              providerOnline = professional.isOnline;
              if ((professional.photoUrl ?? '').isNotEmpty) {
                accountPhotoUrl = professional.photoUrl;
              }
              break;
            }
          }
        }
        notifyListeners();
      },
      onError: (Object error) => _handleRealtimeError(version, error),
    );

    if (activeRole == UserRole.provider) {
      unawaited(_ensureProfessional(version, user.uid, accountName ?? user.displayName ?? 'Prestadora REDGLOW'));
    }

    _bookingsSubscription = _marketplace
        .watchBookings(uid: user.uid, role: activeRole)
        .listen(
      (bookings) {
        if (!_isCurrentSession(version)) return;
        bookingHistory = List.unmodifiable(bookings);
        final booking = _currentBookingFrom(
          bookings,
          activeRole,
          currentBooking,
        );
        final changedBooking = currentBooking?.id != booking?.id;
        if (changedBooking) _clearRatingDetails();
        currentBooking = booking;
        bookingStatus = _statusFromBackend(booking?.status);
        clientToProviderRating = booking?.clientRating ?? 0;
        providerToClientRating = booking?.providerRating ?? 0;
        lastCancellationReason = booking?.cancellationReason ?? '';
        simulatedCancellationFeeCents = booking?.simulatedFeeCents ?? 0;
        if (booking != null) {
          _watchBookingDetails(version, booking);
        } else if (booking == null) {
          _cancelBookingDetailSubscriptions();
        }
        notifyListeners();
      },
      onError: (Object error) => _handleRealtimeError(version, error),
    );

    unawaited(refreshLocation(showPermissionError: false));
  }

  Future<void> _ensureProfessional(int version, String uid, String name) async {
    try {
      await _marketplace.ensureProfessionalProfile(uid: uid, name: name);
    } catch (error) {
      _handleRealtimeError(version, error);
    }
  }

  void _watchBookingDetails(int version, MarketplaceBooking booking) {
    _cancelBookingDetailSubscriptions();
    lastQuickMessage = null;
    _quickMessageSubscription = _marketplace.watchLastQuickMessage(booking.id).listen(
      (message) {
        if (!_isCurrentSession(version)) return;
        lastQuickMessage = message;
        notifyListeners();
      },
      onError: (Object error) => _handleRealtimeError(version, error),
    );
    final bothRated = booking.clientRating > 0 && booking.providerRating > 0;
    if (booking.clientRating > 0 &&
        (activeRole == UserRole.client || bothRated)) {
      _clientRatingSubscription = _marketplace
          .watchRating(bookingId: booking.id, fromUid: booking.clientId)
          .listen(
        (rating) {
          if (!_isCurrentSession(version)) return;
          clientToProviderRating =
              rating?.score ?? currentBooking?.clientRating ?? 0;
          clientToProviderTags = rating?.tags ?? [];
          clientToProviderComment = rating?.comment ?? '';
          notifyListeners();
        },
        onError: (Object error) => _handleRealtimeError(version, error),
      );
    }
    if (booking.providerRating > 0 &&
        (activeRole == UserRole.provider || bothRated)) {
      _providerRatingSubscription = _marketplace
          .watchRating(bookingId: booking.id, fromUid: booking.providerId)
          .listen(
        (rating) {
          if (!_isCurrentSession(version)) return;
          providerToClientRating =
              rating?.score ?? currentBooking?.providerRating ?? 0;
          providerToClientTags = rating?.tags ?? [];
          providerToClientComment = rating?.comment ?? '';
          notifyListeners();
        },
        onError: (Object error) => _handleRealtimeError(version, error),
      );
    }
  }

  void _clearRatingDetails() {
    clientToProviderTags = [];
    providerToClientTags = [];
    clientToProviderComment = '';
    providerToClientComment = '';
  }

  Future<bool> _changeBookingStatus(
    DemoBookingStatus localStatus,
    String backendStatus,
  ) async {
    if (isDemoSession) {
      bookingStatus = localStatus;
      notifyListeners();
      return true;
    }
    final bookingId = currentBooking?.id;
    if (bookingId == null) {
      _setBackendError('Nenhum atendimento foi encontrado para atualizar.');
      return false;
    }
    return _runBackendAction(
      () => _marketplace.updateBookingStatus(
        bookingId,
        backendStatus,
        providerLatitude:
            activeRole == UserRole.provider ? accountLatitude : null,
        providerLongitude:
            activeRole == UserRole.provider ? accountLongitude : null,
      ),
    );
  }

  Future<bool> _runBackendAction(Future<void> Function() action) async {
    backendLoading = true;
    backendError = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseException catch (error) {
      _setBackendError(_firebaseActionMessage(error));
      return false;
    } catch (_) {
      _setBackendError('Não foi possível sincronizar agora. Tente novamente.');
      return false;
    } finally {
      backendLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void _handleRealtimeError(int version, Object error) {
    if (!_isCurrentSession(version)) return;
    backendLoading = false;
    if (error is FirebaseException) {
      _setBackendError(_firebaseActionMessage(error));
    } else {
      _setBackendError('Não foi possível carregar os dados da conta.');
    }
  }

  void _setBackendError(String message) {
    backendError = message;
    if (!_disposed) notifyListeners();
  }

  bool _isCurrentSession(int version) =>
      !_disposed && !isDemoSession && version == _sessionVersion;

  static MarketplaceProfessional? _preserveSelectedProfessional(
    List<MarketplaceProfessional> professionals,
    MarketplaceProfessional? selected,
  ) {
    if (selected != null) {
      for (final professional in professionals) {
        if (professional.uid == selected.uid &&
            professional.isOnline &&
            professional.services.isNotEmpty) {
          return professional;
        }
      }
    }
    for (final professional in professionals) {
      if (professional.isOnline && professional.services.isNotEmpty) {
        return professional;
      }
    }
    return null;
  }

  static MarketplaceBooking? _currentBookingFrom(
    List<MarketplaceBooking> bookings,
    UserRole role,
    MarketplaceBooking? selected,
  ) {
    bool needsAction(MarketplaceBooking booking) {
      if ({
        'requested',
        'accepted',
        'onTheWay',
        'inProgress',
      }.contains(booking.status)) {
        return true;
      }
      return booking.status == 'completed' &&
          (role == UserRole.client
              ? booking.clientRating == 0
              : booking.providerRating == 0);
    }

    if (selected != null) {
      for (final booking in bookings) {
        if (booking.id == selected.id && needsAction(booking)) return booking;
      }
    }
    for (final booking in bookings) {
      if (needsAction(booking)) return booking;
    }
    return bookings.isEmpty ? null : bookings.first;
  }

  static DemoBookingStatus _statusFromBackend(String? status) => switch (status) {
        'requested' => DemoBookingStatus.requested,
        'accepted' => DemoBookingStatus.accepted,
        'onTheWay' => DemoBookingStatus.onTheWay,
        'inProgress' => DemoBookingStatus.inProgress,
        'completed' => DemoBookingStatus.completed,
        'reviewed' => DemoBookingStatus.reviewed,
        'cancelled' => DemoBookingStatus.cancelled,
        _ => DemoBookingStatus.idle,
      };

  static String _firebaseActionMessage(FirebaseException error) =>
      switch (error.code) {
        'permission-denied' =>
          'O Firebase bloqueou esta ação pelas regras de segurança.',
        'failed-precondition' =>
          error.message ??
            'Este perfil ainda não está pronto para receber o pedido.',
        'unavailable' => 'Sem conexão com o Firebase. Tente novamente.',
        'not-found' => 'O registro solicitado não foi encontrado.',
        'already-exists' =>
          error.message ?? 'Esta avaliação já foi registrada.',
        _ => 'Não foi possível sincronizar com o Firebase (${error.code}).',
      };

  void _cancelBookingDetailSubscriptions() {
    unawaited(_quickMessageSubscription?.cancel());
    unawaited(_clientRatingSubscription?.cancel());
    unawaited(_providerRatingSubscription?.cancel());
    _quickMessageSubscription = null;
    _clientRatingSubscription = null;
    _providerRatingSubscription = null;
  }

  void _cancelRealtimeSubscriptions() {
    unawaited(_profileSubscription?.cancel());
    unawaited(_professionalsSubscription?.cancel());
    unawaited(_bookingsSubscription?.cancel());
    _profileSubscription = null;
    _professionalsSubscription = null;
    _bookingsSubscription = null;
    _cancelBookingDetailSubscriptions();
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionVersion++;
    _cancelRealtimeSubscriptions();
    super.dispose();
  }
}

class DemoAppScope extends InheritedNotifier<DemoAppState> {
  const DemoAppScope({
    required DemoAppState controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static DemoAppState of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<DemoAppScope>()
        : context.getInheritedWidgetOfExactType<DemoAppScope>();
    assert(scope != null, 'DemoAppScope não encontrado na árvore de widgets.');
    return scope!.notifier!;
  }
}

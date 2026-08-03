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
  static const pointsRedemptionCost = 10;

  static int auditedPointsForBookings(
    Iterable<MarketplaceBooking> bookings,
  ) {
    return bookings
        .where((booking) => booking.isRewardEligible)
        .fold(0, (total, booking) => total + booking.pointsEarned);
  }

  FirebaseMarketplaceService? _marketplaceService;
  DeviceLocationService? _locationService;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSubscription;
  StreamSubscription<List<MarketplaceProfessional>>? _professionalsSubscription;
  StreamSubscription<List<MarketplaceBooking>>? _bookingsSubscription;
  StreamSubscription<String?>? _quickMessageSubscription;
  StreamSubscription<MarketplaceRating?>? _clientRatingSubscription;
  StreamSubscription<MarketplaceRating?>? _providerRatingSubscription;
  StreamSubscription<List<MarketplaceRewardRedemption>>?
      _rewardRedemptionsSubscription;
  Timer? _providerAvailabilityHeartbeat;
  Timer? _providerRouteTracking;
  int _sessionVersion = 0;
  bool _disposed = false;

  FirebaseMarketplaceService get _marketplace =>
      _marketplaceService ??= FirebaseMarketplaceService();
  DeviceLocationService get _location =>
      _locationService ??= DeviceLocationService();

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
  String? accountAddress;
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
  Map<String, int> demoProviderServicePricesCents =
      RedGlowServiceCatalog.defaultPricesForServices(const [
    'Manicure tradicional',
    'Esmaltação em gel',
    'Spa das mãos',
    'Pedicure tradicional',
    'Spa dos pés',
    'Manicure e pedicure',
  ]);
  String? currentUserId;
  MarketplaceProfessional? selectedProfessional;
  String? selectedServiceName;
  List<String> selectedServiceNames = [];
  MarketplaceBooking? currentBooking;
  List<MarketplaceBooking> bookingHistory = [];
  bool backendLoading = false;
  String? backendError;
  bool providerOnline = true;
  bool providerPresenceReady = true;
  DemoBookingStatus bookingStatus = DemoBookingStatus.idle;
  int points = 0;
  int _legacyPoints = 0;
  int _earnedPoints = 0;
  int _redeemedPoints = 0;
  List<MarketplaceRewardRedemption> rewardRedemptions = [];
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

  String get selectedProviderCode => redGlowPublicCode(
        currentBooking?.providerId ??
            selectedProfessional?.uid ??
            (isDemoSession ? 'demo-lari' : ''),
      );

  String get currentAccountCode => redGlowPublicCode(
        currentUserId ??
            (activeRole == UserRole.provider
                ? 'demo-lari'
                : 'demo-cliente'),
      );

  bool get hasRealProvider =>
      isDemoSession || selectedProfessional?.isOnline == true;

  String get providerSpecialty =>
      selectedProfessional?.specialty ?? demoProviderSpecialty;

  List<String> get providerSpecialties =>
      selectedProfessional?.specialties ?? demoProviderSpecialties;

  int get providerPriceCents =>
      selectedProfessional?.priceCents ?? demoProviderPriceCents;

  Map<String, int> get providerServicePricesCents =>
      selectedProfessional?.servicePricesCents ??
      demoProviderServicePricesCents;

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
    if (accountAddress?.trim().isNotEmpty == true) return accountAddress!;
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
            booking.isRatingEligible &&
            (activeRole == UserRole.client
                ? booking.clientRating == 0
                : booking.providerRating == 0),
      )
      .toList(growable: false);

  List<MarketplaceBooking> get rewardEligibleBookings => bookingHistory
      .where((booking) => booking.isRewardEligible)
      .toList(growable: false);

  int get ignoredLegacyPoints {
    final legacyCompleted = bookingHistory
        .where(
          (booking) =>
              !booking.isCurrentCycle &&
              const {'completed', 'reviewed'}.contains(booking.status),
        )
        .fold(0, (total, booking) => total + booking.pointsEarned);
    return _legacyPoints + legacyCompleted;
  }

  String get selectedService =>
      selectedServices.join(' + ');

  List<String> get selectedServices {
    if (selectedServiceNames.isNotEmpty) {
      return List.unmodifiable(selectedServiceNames);
    }
    final fallback = selectedServiceName ??
        (providerServices.isNotEmpty ? providerServices.first : providerSpecialty);
    return <String>[fallback];
  }

  int get selectedPriceCents => RedGlowServiceCatalog.totalPriceCents(
        selectedServices,
        providerServicePricesCents,
      );

  int get selectedDurationMinutes =>
      RedGlowServiceCatalog.totalMinutes(selectedServices);

  int get selectedPointsEarned =>
      RedGlowServiceCatalog.totalPoints(selectedServices);

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

  void clearBackendError() {
    backendError = null;
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
      providerPresenceReady = true;
      currentUserId = null;
      accountEmail = null;
      accountPhone = null;
      accountPhotoUrl = null;
      accountLatitude = null;
      accountLongitude = null;
      locationAccuracy = null;
      locationUpdatedAt = null;
      accountAddress = null;
      locationError = null;
      selectedProfessional = null;
      selectedServiceName = null;
      selectedServiceNames = [];
      currentBooking = null;
      bookingHistory = [];
      isAdmin = false;
      if (!previousSessionWasDemo) {
        points = 0;
        _legacyPoints = 0;
        _earnedPoints = 0;
        _redeemedPoints = 0;
        rewardRedemptions = [];
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
      providerOnline = false;
      providerPresenceReady = role != UserRole.provider;
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
      selectedServiceNames = [];
      currentBooking = null;
      bookingHistory = [];
      rewardRedemptions = [];
      _legacyPoints = 0;
      _earnedPoints = 0;
      _redeemedPoints = 0;
      isAdmin = false;
      accountPhotoUrl = null;
      accountLatitude = null;
      accountLongitude = null;
      locationAccuracy = null;
      locationUpdatedAt = null;
      accountAddress = null;
      locationError = null;
      _connectRealSession(_sessionVersion);
    }
    notifyListeners();
  }

  Future<bool> requestBooking({String paymentMethod = 'Pix'}) async {
    if (isDemoSession) {
      final now = DateTime.now();
      currentBooking = MarketplaceBooking(
        id: 'demo-${now.microsecondsSinceEpoch}',
        clientId: 'demo-client',
        providerId: selectedProfessional?.uid ?? 'demo-lari',
        clientName: accountName ?? 'Cliente REDGLOW',
        providerName: providerName,
        status: 'requested',
        serviceName: selectedServices.first,
        serviceNames: selectedServices,
        priceCents: selectedPriceCents,
        pointsEarned: selectedPointsEarned,
        address: 'R. Izabel A Redentora, 1000 — Centro, SJP',
        paymentMethod: paymentMethod,
        createdAt: now,
        updatedAt: now,
        clientRating: 0,
        providerRating: 0,
        cancellationReason: '',
        cancelledBy: '',
        simulatedFeeCents: 0,
        schemaVersion: 2,
        completedAt: null,
      );
      bookingHistory = [currentBooking!];
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
        serviceNames: selectedServices,
        paymentMethod: paymentMethod,
        clientLatitude: accountLatitude,
        clientLongitude: accountLongitude,
        address: accountAddress,
      );
    });
  }

  void selectProfessional(
    MarketplaceProfessional professional, {
    String? serviceName,
    List<String>? serviceNames,
  }) {
    selectedProfessional = professional;
    final requestedServices = (serviceNames ??
            (serviceName == null ? const <String>[] : <String>[serviceName]))
        .map((service) => service.trim())
        .where(professional.services.contains)
        .toSet()
        .toList(growable: false);
    selectedServiceNames = requestedServices.isNotEmpty
        ? requestedServices
        : professional.services.isNotEmpty
            ? <String>[professional.services.first]
            : <String>[];
    selectedServiceName =
        selectedServiceNames.isEmpty ? null : selectedServiceNames.first;
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

  Future<bool> completeService() async {
    final shouldCreditDemoPoints =
        isDemoSession && bookingStatus != DemoBookingStatus.completed;
    final completed = await _changeBookingStatus(
      DemoBookingStatus.completed,
      'completed',
    );
    if (completed && shouldCreditDemoPoints) {
      points += currentBooking?.pointsEarned ?? selectedPointsEarned;
      notifyListeners();
    }
    return completed;
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
    } else {
      _configureAvailabilityHeartbeat(value);
    }
    return succeeded;
  }

  void _configureAvailabilityHeartbeat(bool online) {
    _providerAvailabilityHeartbeat?.cancel();
    _providerAvailabilityHeartbeat = null;
    if (!online || isDemoSession || currentUserId == null) return;
    final version = _sessionVersion;
    _providerAvailabilityHeartbeat = Timer.periodic(
      const Duration(minutes: 5),
      (_) async {
        if (!_isCurrentSession(version) || !providerOnline) return;
        try {
          await _marketplace.refreshProviderAvailability(currentUserId!);
        } catch (error) {
          _handleRealtimeError(version, error);
        }
      },
    );
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
        accountAddress =
            'R. Izabel A Redentora, 1000 — Centro, São José dos Pinhais';
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
      accountAddress = result.address ?? accountAddress;
      await _marketplace.updateCurrentLocation(
        uid: userId,
        role: activeRole,
        latitude: result.latitude,
        longitude: result.longitude,
        accuracy: result.accuracy,
        address: result.address,
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
    if (isDemoSession) {
      accountName = cleanName;
      accountPhone = cleanPhone;
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
      ),
    );
  }

  Future<bool> updateProviderServices({
    required List<String> specialties,
    required List<String> services,
    Map<String, int> servicePricesCents = const {},
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
    final validPrices = RedGlowServiceCatalog.sanitizeServicePrices(
      validServices,
      servicePricesCents,
    );
    if (isDemoSession) {
      demoProviderSpecialty = normalizedSpecialties.first;
      demoProviderSpecialties = List.unmodifiable(normalizedSpecialties);
      demoProviderServices = List.unmodifiable(validServices);
      demoProviderServicePricesCents = validPrices;
      demoProviderPriceCents = validPrices.values.reduce(
        (current, next) => current < next ? current : next,
      );
      selectedServiceName = validServices.first;
      selectedServiceNames = [validServices.first];
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
        servicePricesCents: validPrices,
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

  Future<String?> redeemReward({
    required String rewardId,
    required String rewardName,
    required String partnerName,
    required int pointsCost,
  }) async {
    if (points < pointsCost) {
      _setBackendError('Você ainda não possui pontos suficientes para esta troca.');
      return null;
    }
    if (isDemoSession) {
      points -= pointsCost;
      final code = 'RG-DEMO-${rewardRedemptions.length + 1}';
      rewardRedemptions = [
        MarketplaceRewardRedemption(
          id: 'demo-${rewardRedemptions.length + 1}',
          clientId: 'demo-client',
          rewardId: rewardId,
          rewardName: rewardName,
          partnerName: partnerName,
          pointsCost: pointsCost,
          status: 'reserved',
          voucherCode: code,
          createdAt: DateTime.now(),
        ),
        ...rewardRedemptions,
      ];
      notifyListeners();
      return code;
    }
    final userId = currentUserId;
    if (userId == null) {
      _setBackendError('A sessão expirou. Entre novamente.');
      return null;
    }
    String? voucher;
    final success = await _runBackendAction(() async {
      voucher = await _marketplace.redeemReward(
        clientId: userId,
        rewardId: rewardId,
        rewardName: rewardName,
        partnerName: partnerName,
        pointsCost: pointsCost,
      );
    });
    return success ? voucher : null;
  }

  /// Compatibilidade com a vitrine antiga. O fluxo atual usa [redeemReward].
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
        accountAddress = location?['address'] as String? ?? accountAddress;
        isAdmin = data?['isAdmin'] == true;
        _legacyPoints = data?['points'] as int? ?? 0;
        _refreshPointsBalance();
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
              selectedServiceNames.any(
                (service) => !selectedProfessional!.services.contains(service),
              )) {
            selectedServiceNames = selectedProfessional!.services.isNotEmpty
                ? <String>[selectedProfessional!.services.first]
                : <String>[];
            selectedServiceName = selectedServiceNames.isEmpty
                ? null
                : selectedServiceNames.first;
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
        if (activeRole == UserRole.client) {
          _earnedPoints = auditedPointsForBookings(bookings);
          _refreshPointsBalance();
        }
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
        _configureProviderRouteTracking();
        notifyListeners();
      },
      onError: (Object error) => _handleRealtimeError(version, error),
    );

    if (activeRole == UserRole.client) {
      _rewardRedemptionsSubscription =
          _marketplace.watchRewardRedemptions(user.uid).listen(
        (redemptions) {
          if (!_isCurrentSession(version)) return;
          rewardRedemptions = List.unmodifiable(redemptions);
          _redeemedPoints = redemptions.fold(
            0,
            (total, redemption) => total + redemption.pointsCost,
          );
          _refreshPointsBalance();
          notifyListeners();
        },
        onError: (Object error) => _handleRealtimeError(version, error),
      );
    }

    unawaited(refreshLocation(showPermissionError: false));
  }

  Future<void> _ensureProfessional(int version, String uid, String name) async {
    try {
      await _marketplace.ensureProfessionalProfile(uid: uid, name: name);
      if (!_isCurrentSession(version)) return;
      // Cada nova sessão começa offline para impedir que perfis antigos,
      // deixados abertos em outra aba, recebam pedidos por engano.
      await _marketplace.setProviderOnline(uid, false);
      if (!_isCurrentSession(version)) return;
      providerOnline = false;
      providerPresenceReady = true;
      _configureAvailabilityHeartbeat(false);
      notifyListeners();
    } catch (error) {
      providerPresenceReady = false;
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

  void _refreshPointsBalance() {
    // O campo `users.points` e atendimentos anteriores à versão do ciclo
    // auditável são mantidos apenas para diagnóstico. O saldo exibido nasce
    // exclusivamente de conclusões REDGLOW 7.0.8+ e das trocas registradas.
    final balance = _earnedPoints - _redeemedPoints;
    points = balance < 0 ? 0 : balance;
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

  void _configureProviderRouteTracking() {
    _providerRouteTracking?.cancel();
    _providerRouteTracking = null;
    if (isDemoSession ||
        activeRole != UserRole.provider ||
        bookingStatus != DemoBookingStatus.onTheWay ||
        currentBooking == null) {
      return;
    }
    final version = _sessionVersion;
    _providerRouteTracking = Timer.periodic(
      const Duration(seconds: 45),
      (_) => _shareProviderRoutePosition(version),
    );
  }

  Future<void> _shareProviderRoutePosition(int version) async {
    final bookingId = currentBooking?.id;
    if (!_isCurrentSession(version) ||
        bookingId == null ||
        bookingStatus != DemoBookingStatus.onTheWay) {
      return;
    }
    try {
      final result = await _location.current(resolveAddress: false);
      if (!_isCurrentSession(version)) return;
      accountLatitude = result.latitude;
      accountLongitude = result.longitude;
      locationAccuracy = result.accuracy;
      locationUpdatedAt = result.capturedAt;
      await _marketplace.updateBookingProviderLocation(
        bookingId: bookingId,
        latitude: result.latitude,
        longitude: result.longitude,
      );
      if (!_disposed) notifyListeners();
    } on LocationPermissionException catch (error) {
      locationError = error.message;
      _providerRouteTracking?.cancel();
      _providerRouteTracking = null;
      if (!_disposed) notifyListeners();
    } catch (_) {
      // Uma falha isolada de GPS não interrompe o atendimento. O próximo
      // intervalo tenta atualizar novamente.
    }
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
          booking.isRatingEligible &&
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
    return null;
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
    _providerAvailabilityHeartbeat?.cancel();
    _providerAvailabilityHeartbeat = null;
    _providerRouteTracking?.cancel();
    _providerRouteTracking = null;
    unawaited(_profileSubscription?.cancel());
    unawaited(_professionalsSubscription?.cancel());
    unawaited(_bookingsSubscription?.cancel());
    unawaited(_rewardRedemptionsSubscription?.cancel());
    _profileSubscription = null;
    _professionalsSubscription = null;
    _bookingsSubscription = null;
    _rewardRedemptionsSubscription = null;
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

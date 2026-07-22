import 'package:flutter/material.dart';

import '../models/user_role.dart';

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
  UserRole activeRole = UserRole.client;
  bool isDemoSession = true;
  String? accountName;
  DemoBookingStatus bookingStatus = DemoBookingStatus.idle;
  int points = 2480;
  bool clientIdentityVerified = false;
  bool providerIdentityVerified = false;
  bool professionalPlanActive = false;
  String? lastQuickMessage;
  int clientToProviderRating = 0;
  int providerToClientRating = 0;

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
    activeRole = role;
    isDemoSession = demo;
    accountName = name;
    notifyListeners();
  }

  void requestBooking() {
    bookingStatus = DemoBookingStatus.requested;
    lastQuickMessage = null;
    clientToProviderRating = 0;
    providerToClientRating = 0;
    notifyListeners();
  }

  void acceptBooking() {
    bookingStatus = DemoBookingStatus.accepted;
    notifyListeners();
  }

  void startTrip() {
    bookingStatus = DemoBookingStatus.onTheWay;
    notifyListeners();
  }

  void startService() {
    bookingStatus = DemoBookingStatus.inProgress;
    notifyListeners();
  }

  void completeService() {
    bookingStatus = DemoBookingStatus.completed;
    notifyListeners();
  }

  void cancelBooking() {
    bookingStatus = DemoBookingStatus.cancelled;
    notifyListeners();
  }

  void sendQuickMessage(String message) {
    lastQuickMessage = message;
    notifyListeners();
  }

  void submitRating(int rating, {bool asProvider = false}) {
    if (asProvider) {
      providerToClientRating = rating;
    } else {
      if (clientToProviderRating == 0) points += 60;
      clientToProviderRating = rating;
      bookingStatus = DemoBookingStatus.reviewed;
    }
    notifyListeners();
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
    if (points < 2500) return false;
    points -= 2500;
    notifyListeners();
    return true;
  }

  void resetBooking() {
    bookingStatus = DemoBookingStatus.idle;
    lastQuickMessage = null;
    clientToProviderRating = 0;
    providerToClientRating = 0;
    notifyListeners();
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

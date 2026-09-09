import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../services/firebase_marketplace_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cancellation_flow.dart';
import '../widgets/common_widgets.dart';
import 'rating_screen.dart';
import 'reviews_screen.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final entries = state.isDemoSession
        ? _demoEntries(state, role)
        : state.bookingHistory
            .map(
              (booking) => _fromBooking(
                booking,
                role,
              ),
            )
            .toList();
    return Scaffold(
      body: ConstrainedMobileBody(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Histórico de atendimentos', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                        Text('Serviços, valores e situações anteriores', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                const GlowCard(
                  child: Column(
                    children: [
                      Icon(Icons.event_note_outlined, color: AppColors.textMuted, size: 42),
                      SizedBox(height: 9),
                      Text('Nenhum atendimento no histórico.', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              else
                for (final entry in entries)
                  _HistoryCard(
                    entry: entry,
                    onCancel: entry.cancellable
                        ? () async {
                            for (final booking in state.bookingHistory) {
                              if (booking.id == entry.bookingId) {
                                state.selectBooking(booking);
                                break;
                              }
                            }
                            await showCancellationFlow(
                              context,
                              asProvider: role == UserRole.provider,
                            );
                          }
                        : null,
                    onReview: entry.pendingReview
                        ? () {
                            MarketplaceBooking? booking;
                            for (final candidate
                                in state.bookingHistory) {
                              if (candidate.id == entry.bookingId) {
                                booking = candidate;
                                break;
                              }
                            }
                            if (booking != null) {
                              state.selectBooking(booking);
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RatingScreen(
                                  reviewingClient:
                                      role == UserRole.provider,
                                  bookingId: entry.bookingId,
                                ),
                              ),
                            );
                          }
                        : null,
                    onReviews: entry.reviewed
                        ? () {
                            for (final booking in state.bookingHistory) {
                              if (booking.id == entry.bookingId) {
                                state.selectBooking(booking);
                                break;
                              }
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReviewsScreen(
                                  viewingAsProvider:
                                      role == UserRole.provider,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
              if (state.isDemoSession) ...[
                const SizedBox(height: 4),
                const Text(
                  'Os dois registros anteriores são exemplos visuais. O atendimento atual acompanha o ciclo que você testou.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 8, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static List<_HistoryEntry> _demoEntries(DemoAppState state, UserRole role) {
    final counterpart = role == UserRole.provider ? state.clientName : state.providerName;
    return [
      if (state.bookingStatus != DemoBookingStatus.idle)
        _HistoryEntry(
          counterpart: counterpart,
          service: 'Manicure e Pedicure',
          price: 'R\$ 60,00',
          date: 'Hoje',
          status: state.bookingStatus.label,
          color: _statusColor(state.bookingStatus),
          reviewed: state.bookingStatus == DemoBookingStatus.reviewed,
          pendingReview:
              state.bookingStatus == DemoBookingStatus.completed,
          providerCode: state.selectedProviderCode,
          cancellable: const {
            DemoBookingStatus.requested,
            DemoBookingStatus.accepted,
            DemoBookingStatus.onTheWay,
          }.contains(state.bookingStatus),
        ),
      const _HistoryEntry(
        counterpart: 'Atendimento demonstrativo',
        service: 'Manicure',
        price: 'R\$ 35,00',
        date: '18 Jul',
        status: 'Serviço concluído',
        color: AppColors.green,
        reviewed: false,
        pendingReview: false,
      ),
      const _HistoryEntry(
        counterpart: 'Atendimento demonstrativo',
        service: 'Pedicure',
        price: 'R\$ 30,00',
        date: '12 Jul',
        status: 'Serviço concluído',
        color: AppColors.green,
        reviewed: false,
        pendingReview: false,
      ),
    ];
  }

  static _HistoryEntry _fromBooking(
    MarketplaceBooking booking,
    UserRole role,
  ) {
    final status = switch (booking.status) {
      'requested' => 'Solicitado',
      'accepted' => 'Aceito',
      'onTheWay' => 'A caminho',
      'inProgress' => 'Em atendimento',
      'completed' => 'Serviço concluído',
      'reviewed' => 'Avaliado',
      'cancelled' => 'Cancelado',
      _ => booking.status,
    };
    final value = (booking.priceCents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return _HistoryEntry(
      counterpart: role == UserRole.provider ? booking.clientName : booking.providerName,
      service: booking.serviceNames.join(' + '),
      price: 'R\$ $value',
      date: '${booking.createdAt.day.toString().padLeft(2, '0')}/${booking.createdAt.month.toString().padLeft(2, '0')}',
      status: status,
      color: booking.status == 'cancelled' ? Colors.redAccent : AppColors.green,
      reviewed: booking.status == 'reviewed',
      pendingReview: booking.status == 'completed' &&
          booking.isRatingEligible &&
          (role == UserRole.client
              ? booking.clientRating == 0
              : booking.providerRating == 0),
      bookingId: booking.id,
      providerCode: booking.providerPublicCode,
      cancellable: booking.isCancellable,
      cancellationReason: booking.cancellationReason,
      legacy: !booking.isCurrentCycle,
    );
  }

  static Color _statusColor(DemoBookingStatus status) => switch (status) {
        DemoBookingStatus.cancelled => Colors.redAccent,
        DemoBookingStatus.completed || DemoBookingStatus.reviewed => AppColors.green,
        DemoBookingStatus.onTheWay || DemoBookingStatus.inProgress => AppColors.route,
        _ => AppColors.primary,
      };
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.counterpart,
    required this.service,
    required this.price,
    required this.date,
    required this.status,
    required this.color,
    required this.reviewed,
    required this.pendingReview,
    this.bookingId,
    this.providerCode,
    this.cancellable = false,
    this.cancellationReason = '',
    this.legacy = false,
  });
  final String counterpart;
  final String service;
  final String price;
  final String date;
  final String status;
  final Color color;
  final bool reviewed;
  final bool pendingReview;
  final String? bookingId;
  final String? providerCode;
  final bool cancellable;
  final String cancellationReason;
  final bool legacy;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    this.onCancel,
    this.onReview,
    this.onReviews,
  });
  final _HistoryEntry entry;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;
  final VoidCallback? onReviews;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      margin: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(entry.counterpart, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
              Text(entry.price, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            entry.providerCode == null
                ? entry.service
                : '${entry.service} · ${entry.providerCode}',
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
          if (entry.legacy) ...[
            const SizedBox(height: 5),
            const Text(
              'Registro anterior ao ciclo auditável · sem pontos ou pendência de avaliação',
              style: TextStyle(fontSize: 8, color: AppColors.textMuted),
            ),
          ],
          if (entry.cancellationReason.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Motivo: ${entry.cancellationReason}',
              style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
            ),
          ],
          const Divider(height: 18),
          Row(
            children: [
              Text(entry.date, style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
              const Spacer(),
              StatusPill(label: entry.status.toUpperCase(), color: entry.color),
            ],
          ),
          if (onReviews != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onReviews,
                icon: const Icon(Icons.reviews_outlined, size: 17),
                label: const Text('Ver avaliação e relato'),
              ),
            ),
          ],
          if (onReview != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.star_outline_rounded, size: 17),
                label: const Text('Avaliar este atendimento'),
              ),
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: Key('cancel-booking-${entry.bookingId ?? 'demo'}'),
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: .65),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 17),
                label: const Text('Cancelar atendimento'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

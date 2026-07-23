import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../services/firebase_marketplace_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
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
                state.currentBooking?.id,
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
                    onReviews: entry.reviewed
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReviewsScreen(
                                  viewingAsProvider: role == UserRole.provider,
                                ),
                              ),
                            )
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
        ),
      const _HistoryEntry(
        counterpart: 'Atendimento demonstrativo',
        service: 'Manicure',
        price: 'R\$ 35,00',
        date: '18 Jul',
        status: 'Serviço concluído',
        color: AppColors.green,
        reviewed: false,
      ),
      const _HistoryEntry(
        counterpart: 'Atendimento demonstrativo',
        service: 'Pedicure',
        price: 'R\$ 30,00',
        date: '12 Jul',
        status: 'Serviço concluído',
        color: AppColors.green,
        reviewed: false,
      ),
    ];
  }

  static _HistoryEntry _fromBooking(
    MarketplaceBooking booking,
    UserRole role,
    String? currentBookingId,
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
      service: booking.serviceName,
      price: 'R\$ $value',
      date: '${booking.createdAt.day.toString().padLeft(2, '0')}/${booking.createdAt.month.toString().padLeft(2, '0')}',
      status: status,
      color: booking.status == 'cancelled' ? Colors.redAccent : AppColors.green,
      reviewed: booking.status == 'reviewed' && booking.id == currentBookingId,
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
  });
  final String counterpart;
  final String service;
  final String price;
  final String date;
  final String status;
  final Color color;
  final bool reviewed;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry, this.onReviews});
  final _HistoryEntry entry;
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
          Text(entry.service, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
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
        ],
      ),
    );
  }
}

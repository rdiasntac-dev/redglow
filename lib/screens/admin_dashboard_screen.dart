import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firebase_marketplace_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, this.preview = false});

  final bool preview;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _section = 0;
  bool _maintenanceBusy = false;

  Future<void> _archiveLegacyBookings(
    List<_AdminBooking> bookings,
  ) async {
    final state = DemoAppScope.of(context, listen: false);
    final adminUid = state.currentUserId;
    final legacyIds = bookings
        .where((booking) => booking.isLegacy && !booking.archived)
        .map((booking) => booking.id)
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    if (adminUid == null || legacyIds.isEmpty) return;
    setState(() => _maintenanceBusy = true);
    try {
      await FirebaseMarketplaceService().archiveLegacyBookings(
        bookingIds: legacyIds,
        adminUid: adminUid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${legacyIds.length} registro(s) beta arquivado(s) com segurança.',
          ),
        ),
      );
    } on FirebaseException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O Firebase não autorizou a manutenção administrativa.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _maintenanceBusy = false);
    }
  }

  Future<void> _restoreBooking(String bookingId) async {
    if (bookingId.isEmpty) return;
    setState(() => _maintenanceBusy = true);
    try {
      await FirebaseMarketplaceService().restoreArchivedBooking(bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro restaurado no histórico beta.')),
      );
    } on FirebaseException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível restaurar o registro.')),
      );
    } finally {
      if (mounted) setState(() => _maintenanceBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    if (!state.isAdmin && !widget.preview) {
      return Scaffold(
        body: ConstrainedMobileBody(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.admin_panel_settings_outlined, color: AppColors.textMuted, size: 64),
                    const SizedBox(height: 14),
                    const Text('Acesso administrativo restrito', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    const Text(
                      'Esta conta não possui permissão administrativa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.preview) {
      return _AdminLayout(
        section: _section,
        onSectionChanged: (value) => setState(() => _section = value),
        users: const [
          _AdminUser('Cliente Beta', 'cliente', 'cliente@beta.redglow'),
          _AdminUser('Lari (Manicure)', 'prestadora', 'lari@beta.redglow'),
        ],
        bookings: const [
          _AdminBooking(
            'preview-booking',
            'Cliente Beta',
            'Lari (Manicure)',
            'concluído',
            1,
            false,
            '',
          ),
        ],
        reports: const [
          _AdminReport('Segurança', 'Relato demonstrativo para validar a fila operacional.', 'aberto', ''),
        ],
        maintenanceBusy: false,
        onArchiveLegacy: null,
        onRestoreBooking: null,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, usersSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
          builder: (context, bookingsSnapshot) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('reports').snapshots(),
              builder: (context, reportsSnapshot) {
                if (usersSnapshot.hasError || bookingsSnapshot.hasError || reportsSnapshot.hasError) {
                  return _AdminError(onBack: () => Navigator.of(context).pop());
                }
                if (!usersSnapshot.hasData || !bookingsSnapshot.hasData || !reportsSnapshot.hasData) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                final users = usersSnapshot.data!.docs.map((document) {
                  final data = document.data();
                  return _AdminUser(
                    data['name'] as String? ?? 'Usuário',
                    data['role'] == 'provider' ? 'prestadora' : 'cliente',
                    data['email'] as String? ?? '',
                  );
                }).toList(growable: false);
                final bookings = bookingsSnapshot.data!.docs.map((document) {
                  final data = document.data();
                  return _AdminBooking(
                    document.id,
                    data['clientName'] as String? ?? 'Cliente',
                    data['providerName'] as String? ?? 'Prestadora',
                    _statusLabel(data['status'] as String? ?? ''),
                    data['schemaVersion'] as int? ?? 1,
                    data['archivedAt'] is Timestamp,
                    data['archiveReason'] as String? ?? '',
                  );
                }).toList(growable: false);
                final reports = reportsSnapshot.data!.docs.map((document) {
                  final data = document.data();
                  return _AdminReport(
                    data['category'] as String? ?? 'Outro',
                    data['description'] as String? ?? '',
                    _reportStatusLabel(data['status'] as String? ?? 'open'),
                    document.id,
                  );
                }).toList(growable: false);
                return _AdminLayout(
                  section: _section,
                  onSectionChanged: (value) => setState(() => _section = value),
                  users: users,
                  bookings: bookings,
                  reports: reports,
                  maintenanceBusy: _maintenanceBusy,
                  onArchiveLegacy: () => _archiveLegacyBookings(bookings),
                  onRestoreBooking: _restoreBooking,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AdminLayout extends StatelessWidget {
  const _AdminLayout({
    required this.section,
    required this.onSectionChanged,
    required this.users,
    required this.bookings,
    required this.reports,
    required this.maintenanceBusy,
    required this.onArchiveLegacy,
    required this.onRestoreBooking,
  });

  final int section;
  final ValueChanged<int> onSectionChanged;
  final List<_AdminUser> users;
  final List<_AdminBooking> bookings;
  final List<_AdminReport> reports;
  final bool maintenanceBusy;
  final VoidCallback? onArchiveLegacy;
  final ValueChanged<String>? onRestoreBooking;

  @override
  Widget build(BuildContext context) {
    final openReports = reports.where((item) => item.status != 'resolvido').length;
    final activeBookings = bookings.where((item) => !item.archived).length;
    final legacyBookings = bookings
        .where((item) => item.isLegacy && !item.archived)
        .length;
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
                        Text('Painel operacional', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                        Text('Acesso restrito REDGLOW', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const StatusPill(label: 'ADMIN', color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _AdminMetric(label: 'Usuários', value: '${users.length}', color: AppColors.purple)),
                  const SizedBox(width: 7),
                  Expanded(child: _AdminMetric(label: 'Atendimentos', value: '$activeBookings', color: AppColors.green)),
                  const SizedBox(width: 7),
                  Expanded(child: _AdminMetric(label: 'Relatos abertos', value: '$openReports', color: Colors.redAccent)),
                ],
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(child: _AdminSectionButton(label: 'Relatos', selected: section == 0, onTap: () => onSectionChanged(0))),
                  const SizedBox(width: 6),
                  Expanded(child: _AdminSectionButton(label: 'Usuários', selected: section == 1, onTap: () => onSectionChanged(1))),
                  const SizedBox(width: 6),
                  Expanded(child: _AdminSectionButton(label: 'Atendimentos', selected: section == 2, onTap: () => onSectionChanged(2))),
                ],
              ),
              const SizedBox(height: 12),
              if (section == 0)
                if (reports.isEmpty)
                  const _EmptyAdminState(message: 'Nenhum relato recebido.')
                else
                  for (final report in reports) _ReportAdminCard(report: report)
              else if (section == 1)
                if (users.isEmpty)
                  const _EmptyAdminState(message: 'Nenhum usuário encontrado.')
                else
                  for (final user in users)
                    GlowCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, color: AppColors.purple),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                                Text(user.email, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          StatusPill(label: user.role.toUpperCase(), color: AppColors.purple),
                        ],
                      ),
                    )
              else if (bookings.isEmpty)
                const _EmptyAdminState(message: 'Nenhum atendimento encontrado.')
              else ...[
                if (legacyBookings > 0)
                  GlowCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    borderColor: AppColors.yellow.withValues(alpha: .55),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MANUTENÇÃO DO BETA',
                          style: TextStyle(
                            color: AppColors.yellow,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$legacyBookings registro(s) anterior(es) ao ciclo auditável. '
                          'O arquivamento remove esses dados das telas sem apagá-los.',
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 9),
                        FilledButton.icon(
                          onPressed: maintenanceBusy ? null : onArchiveLegacy,
                          icon: const Icon(Icons.inventory_2_outlined, size: 17),
                          label: Text(
                            maintenanceBusy
                                ? 'Processando…'
                                : 'Arquivar registros antigos',
                          ),
                        ),
                      ],
                    ),
                  ),
                for (final booking in bookings)
                  GlowCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: booking.archived
                        ? AppColors.surfaceRaised.withValues(alpha: .55)
                        : AppColors.surface,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              booking.archived
                                  ? Icons.inventory_2_outlined
                                  : Icons.event_note_outlined,
                              color: booking.archived
                                  ? AppColors.textMuted
                                  : AppColors.green,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${booking.client} → ${booking.provider}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    booking.archived
                                        ? booking.archiveReason
                                        : 'Ciclo ${booking.schemaVersion >= 2 ? 'auditável' : 'beta legado'}',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusPill(
                              label: booking.archived
                                  ? 'ARQUIVADO'
                                  : booking.status.toUpperCase(),
                              color: booking.archived
                                  ? AppColors.textMuted
                                  : AppColors.green,
                            ),
                          ],
                        ),
                        if (booking.archived && onRestoreBooking != null) ...[
                          const SizedBox(height: 7),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: maintenanceBusy
                                  ? null
                                  : () => onRestoreBooking!(booking.id),
                              icon: const Icon(Icons.restore_rounded, size: 16),
                              label: const Text('Restaurar'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportAdminCard extends StatelessWidget {
  const _ReportAdminCard({required this.report});

  final _AdminReport report;

  Future<void> _markResolved(BuildContext context) async {
    if (report.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ação simulada no painel de demonstração.')));
      return;
    }
    await FirebaseFirestore.instance.collection('reports').doc(report.id).update({
      'status': 'resolved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      margin: const EdgeInsets.only(bottom: 8),
      borderColor: report.status == 'resolvido' ? AppColors.border : const Color(0xFF6E2434),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.report_outlined, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(report.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
              StatusPill(label: report.status.toUpperCase(), color: report.status == 'resolvido' ? AppColors.green : Colors.redAccent),
            ],
          ),
          const SizedBox(height: 9),
          Text(report.description, style: const TextStyle(fontSize: 9, height: 1.4, color: AppColors.textSecondary)),
          if (report.status != 'resolvido') ...[
            const SizedBox(height: 9),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _markResolved(context),
                icon: const Icon(Icons.task_alt_rounded, size: 17),
                label: const Text('Marcar como resolvido'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdminMetric extends StatelessWidget {
  const _AdminMetric({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => GlowCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: color)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 7, color: AppColors.textMuted)),
          ],
        ),
      );
}

class _AdminSectionButton extends StatelessWidget {
  const _AdminSectionButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? AppColors.primary.withValues(alpha: .14) : null,
          side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(label, style: TextStyle(fontSize: 8, color: selected ? AppColors.primary : AppColors.textSecondary)),
      );
}

class _EmptyAdminState extends StatelessWidget {
  const _EmptyAdminState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => GlowCard(
        child: Center(child: Text(message, style: const TextStyle(color: AppColors.textSecondary))),
      );
}

class _AdminError extends StatelessWidget {
  const _AdminError({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Não foi possível carregar o painel.'),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: onBack, child: const Text('Voltar')),
            ],
          ),
        ),
      );
}

class _AdminUser {
  const _AdminUser(this.name, this.role, this.email);
  final String name;
  final String role;
  final String email;
}

class _AdminBooking {
  const _AdminBooking(
    this.id,
    this.client,
    this.provider,
    this.status,
    this.schemaVersion,
    this.archived,
    this.archiveReason,
  );
  final String id;
  final String client;
  final String provider;
  final String status;
  final int schemaVersion;
  final bool archived;
  final String archiveReason;

  bool get isLegacy => schemaVersion < 2;
}

class _AdminReport {
  const _AdminReport(this.category, this.description, this.status, this.id);
  final String category;
  final String description;
  final String status;
  final String id;
}

String _statusLabel(String status) => switch (status) {
      'requested' => 'solicitado',
      'accepted' => 'aceito',
      'onTheWay' => 'a caminho',
      'inProgress' => 'em serviço',
      'completed' => 'concluído',
      'reviewed' => 'avaliado',
      'cancelled' => 'cancelado',
      _ => status,
    };

String _reportStatusLabel(String status) => switch (status) {
      'open' => 'aberto',
      'reviewing' => 'em análise',
      'resolved' => 'resolvido',
      _ => status,
    };

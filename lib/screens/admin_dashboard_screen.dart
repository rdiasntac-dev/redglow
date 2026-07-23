import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          _AdminBooking('Cliente Beta', 'Lari (Manicure)', 'concluído'),
        ],
        reports: const [
          _AdminReport('Segurança', 'Relato demonstrativo para validar a fila operacional.', 'aberto', ''),
        ],
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
                    data['clientName'] as String? ?? 'Cliente',
                    data['providerName'] as String? ?? 'Prestadora',
                    _statusLabel(data['status'] as String? ?? ''),
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
  });

  final int section;
  final ValueChanged<int> onSectionChanged;
  final List<_AdminUser> users;
  final List<_AdminBooking> bookings;
  final List<_AdminReport> reports;

  @override
  Widget build(BuildContext context) {
    final openReports = reports.where((item) => item.status != 'resolvido').length;
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
                  Expanded(child: _AdminMetric(label: 'Atendimentos', value: '${bookings.length}', color: AppColors.green)),
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
              else
                for (final booking in bookings)
                  GlowCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note_outlined, color: AppColors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${booking.client} → ${booking.provider}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                              const Text('Manicure e Pedicure · R\$ 60,00', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        StatusPill(label: booking.status.toUpperCase(), color: AppColors.green),
                      ],
                    ),
                  ),
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
  const _AdminBooking(this.client, this.provider, this.status);
  final String client;
  final String provider;
  final String status;
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

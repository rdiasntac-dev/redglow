import 'package:flutter/material.dart';

import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

enum _AnalyticsRange { week, month, quarter }

class ProviderAnalyticsScreen extends StatefulWidget {
  const ProviderAnalyticsScreen({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  @override
  State<ProviderAnalyticsScreen> createState() =>
      _ProviderAnalyticsScreenState();
}

class _ProviderAnalyticsScreenState extends State<ProviderAnalyticsScreen> {
  _AnalyticsRange _range = _AnalyticsRange.month;
  int _selectedBar = 3;

  _PerformanceData get _data => switch (_range) {
        _AnalyticsRange.week => const _PerformanceData(
            title: 'Últimos 7 dias',
            labels: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
            values: [125, 60, 210, 95, 180, 140, 225],
            appointments: 16,
            growth: 12,
          ),
        _AnalyticsRange.month => const _PerformanceData(
            title: 'Julho',
            labels: ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'],
            values: [320, 460, 515, 545],
            appointments: 28,
            growth: 18,
          ),
        _AnalyticsRange.quarter => const _PerformanceData(
            title: 'Últimos 90 dias',
            labels: ['Mai', 'Jun', 'Jul'],
            values: [1260, 1540, 1840],
            appointments: 71,
            growth: 46,
          ),
      };

  void _selectRange(_AnalyticsRange value) {
    setState(() {
      _range = value;
      _selectedBar = _data.values.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final data = state.isDemoSession
        ? _demoDataWithCurrentCycle(state)
        : _realData(state);
    final total = data.values.fold<double>(0, (sum, value) => sum + value);
    final ticket = data.appointments == 0 ? 0.0 : total / data.appointments;
    final serviceShares = _serviceShares(state);

    final content = ConstrainedMobileBody(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              14,
              6,
              14,
              widget.embedded ? 96 : 28,
            ),
            children: [
              Row(
                children: [
                  if (!widget.embedded) ...[
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 11),
                  ],
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ganhos e desempenho',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Visão financeira da prestadora',
                          style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const StatusPill(
                    label: 'BETA',
                    color: AppColors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!state.isDemoSession) ...[
                const GlowCard(
                  borderColor: AppColors.yellow,
                  color: Color(0xFF211D10),
                  child: Row(
                    children: [
                      Icon(Icons.science_outlined, color: AppColors.yellow),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Os valores abaixo são demonstrativos. O histórico real será calculado somente com atendimentos e repasses confirmados.',
                          style: TextStyle(fontSize: 9, height: 1.45, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: _RangeChoice(
                      label: '7 dias',
                      selected: _range == _AnalyticsRange.week,
                      onTap: () => _selectRange(_AnalyticsRange.week),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _RangeChoice(
                      label: '30 dias',
                      selected: _range == _AnalyticsRange.month,
                      onTap: () => _selectRange(_AnalyticsRange.month),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _RangeChoice(
                      label: '90 dias',
                      selected: _range == _AnalyticsRange.quarter,
                      onTap: () => _selectRange(_AnalyticsRange.quarter),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlowCard(
                key: const Key('provider-analytics-chart'),
                borderColor: AppColors.purple.withValues(alpha: .48),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF291231), Color(0xFF17101E)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _money(total),
                                style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        StatusPill(
                          label: '+${data.growth.toStringAsFixed(0)}%',
                          color: AppColors.green,
                          icon: Icons.trending_up_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InteractiveBarChart(
                      data: data,
                      selectedIndex: _selectedBar,
                      onSelected: (index) => setState(() => _selectedBar = index),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: .28)),
                      ),
                      child: Text(
                        '${data.labels[_selectedBar]} · ${_money(data.values[_selectedBar])} em serviços',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.event_available_rounded,
                      value: '${data.appointments}',
                      label: 'Atendimentos',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.receipt_long_outlined,
                      value: _money(ticket),
                      label: 'Ticket médio',
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SERVIÇOS MAIS PROCURADOS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 13),
                    if (serviceShares.isEmpty)
                      const Text(
                        'Conclua atendimentos para formar este ranking.',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      for (var index = 0;
                          index < serviceShares.length;
                          index++) ...[
                        _ServiceShare(
                          label: serviceShares[index].label,
                          percentage: serviceShares[index].percentage,
                          color: [
                            AppColors.primary,
                            AppColors.purple,
                            AppColors.route,
                          ][index % 3],
                        ),
                        if (index < serviceShares.length - 1)
                          const SizedBox(height: 11),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GlowCard(
                borderColor: Color(0xFF275E51),
                color: Color(0xFF10221E),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.green,
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Insight REDGLOW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            serviceShares.isEmpty
                                ? 'O painel aprenderá com seus atendimentos concluídos. Não exibiremos serviços fora dos nichos selecionados.'
                                : '${serviceShares.first.label} representa '
                                    '${(serviceShares.first.percentage * 100).round()}% '
                                    'dos atendimentos concluídos no período.',
                            style: const TextStyle(
                              fontSize: 9,
                              height: 1.45,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Painel demonstrativo: valores não representam saldo disponível para saque.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    return widget.embedded ? content : Scaffold(body: content);
  }

  _PerformanceData _realData(DemoAppState state) {
    final completed = state.bookingHistory
        .where(
          (booking) =>
              booking.status == 'completed' ||
              booking.status == 'reviewed',
        )
        .toList(growable: false);
    final now = DateTime.now();
    final labels = switch (_range) {
      _AnalyticsRange.week =>
        const ['D-6', 'D-5', 'D-4', 'D-3', 'D-2', 'Ontem', 'Hoje'],
      _AnalyticsRange.month =>
        const ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'],
      _AnalyticsRange.quarter =>
        const ['Mês 1', 'Mês 2', 'Mês atual'],
    };
    final values = List<double>.filled(labels.length, 0);
    var appointments = 0;
    for (final booking in completed) {
      final days = now.difference(booking.updatedAt).inDays;
      int? index;
      switch (_range) {
        case _AnalyticsRange.week:
          if (days >= 0 && days < 7) index = 6 - days;
          break;
        case _AnalyticsRange.month:
          if (days >= 0 && days < 28) index = 3 - (days ~/ 7);
          break;
        case _AnalyticsRange.quarter:
          if (days >= 0 && days < 90) index = 2 - (days ~/ 30);
          break;
      }
      if (index != null && index >= 0 && index < values.length) {
        values[index] += booking.priceCents / 100;
        appointments++;
      }
    }
    return _PerformanceData(
      title: switch (_range) {
        _AnalyticsRange.week => 'Últimos 7 dias',
        _AnalyticsRange.month => 'Últimos 28 dias',
        _AnalyticsRange.quarter => 'Últimos 90 dias',
      },
      labels: labels,
      values: values,
      appointments: appointments,
      growth: 0,
    );
  }

  _PerformanceData _demoDataWithCurrentCycle(DemoAppState state) {
    final base = _data;
    final hasCompletedTest = {
      DemoBookingStatus.completed,
      DemoBookingStatus.reviewed,
    }.contains(state.bookingStatus);
    if (!hasCompletedTest) return base;
    final values = List<double>.of(base.values);
    values[values.length - 1] += state.providerPriceCents / 100;
    return _PerformanceData(
      title: base.title,
      labels: base.labels,
      values: values,
      appointments: base.appointments + 1,
      growth: base.growth,
    );
  }

  List<_ServiceShareData> _serviceShares(DemoAppState state) {
    if (state.isDemoSession) {
      final services = state.providerServices.take(3).toList();
      if (services.isEmpty) return const [];
      const demoShares = [.52, .28, .20];
      return [
        for (var index = 0; index < services.length; index++)
          _ServiceShareData(
            services[index],
            demoShares[index],
          ),
      ];
    }
    final counts = <String, int>{};
    for (final booking in state.bookingHistory) {
      if ((booking.status == 'completed' ||
              booking.status == 'reviewed') &&
          state.providerServices.contains(booking.serviceName)) {
        counts.update(
          booking.serviceName,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    if (total == 0) return const [];
    return entries
        .take(3)
        .map(
          (entry) => _ServiceShareData(
            entry.key,
            entry.value / total,
          ),
        )
        .toList(growable: false);
  }
}

class _RangeChoice extends StatelessWidget {
  const _RangeChoice({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _InteractiveBarChart extends StatelessWidget {
  const _InteractiveBarChart({
    required this.data,
    required this.selectedIndex,
    required this.onSelected,
  });

  final _PerformanceData data;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final rawMax = data.values.reduce((a, b) => a > b ? a : b);
    final maxValue = rawMax <= 0 ? 1.0 : rawMax;
    return SizedBox(
      height: 142,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < data.values.length; index++)
            Expanded(
              child: Semantics(
                button: true,
                selected: index == selectedIndex,
                label: '${data.labels[index]}, ${_money(data.values[index])}',
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 100 * (data.values[index] / maxValue),
                          decoration: BoxDecoration(
                            gradient: index == selectedIndex ? pinkGradient : null,
                            color: index == selectedIndex
                                ? null
                                : AppColors.purple.withValues(alpha: .22),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                            border: Border.all(
                              color: index == selectedIndex
                                  ? AppColors.primary.withValues(alpha: .7)
                                  : AppColors.purple.withValues(alpha: .2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          data.labels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: index == selectedIndex ? FontWeight.w900 : FontWeight.w500,
                            color: index == selectedIndex ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.label, required this.color});

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                Text(label, style: const TextStyle(fontSize: 7, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceShare extends StatelessWidget {
  const _ServiceShare({required this.label, required this.percentage, required this.color});

  final String label;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700))),
            Text('${(percentage * 100).round()}%', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: AppColors.surfaceRaised,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _PerformanceData {
  const _PerformanceData({
    required this.title,
    required this.labels,
    required this.values,
    required this.appointments,
    required this.growth,
  });

  final String title;
  final List<String> labels;
  final List<double> values;
  final int appointments;
  final double growth;
}

class _ServiceShareData {
  const _ServiceShareData(this.label, this.percentage);

  final String label;
  final double percentage;
}

String _money(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final integer = parts.first;
  final grouped = StringBuffer();
  for (var index = 0; index < integer.length; index++) {
    if (index > 0 && (integer.length - index) % 3 == 0) grouped.write('.');
    grouped.write(integer[index]);
  }
  return 'R\$ $grouped,${parts.last}';
}

import 'package:flutter/material.dart';

import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

enum _AnalyticsRange { week, month, quarter }

class ProviderAnalyticsScreen extends StatefulWidget {
  const ProviderAnalyticsScreen({super.key});

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
    final data = _data;
    final total = data.values.fold<double>(0, (sum, value) => sum + value);
    final ticket = total / data.appointments;

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
              const GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SERVIÇOS MAIS PROCURADOS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                    SizedBox(height: 13),
                    _ServiceShare(label: 'Manicure e Pedicure', percentage: .52, color: AppColors.primary),
                    SizedBox(height: 11),
                    _ServiceShare(label: 'Manicure', percentage: .28, color: AppColors.purple),
                    SizedBox(height: 11),
                    _ServiceShare(label: 'Pedicure', percentage: .20, color: AppColors.route),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const GlowCard(
                borderColor: Color(0xFF275E51),
                color: Color(0xFF10221E),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.green, size: 21),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Insight REDGLOW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                          SizedBox(height: 4),
                          Text(
                            'Manicure e Pedicure representa 52% da procura. Na simulação, abrir dois horários extras nos dias de maior movimento pode elevar o faturamento sem reduzir o ticket médio.',
                            style: TextStyle(fontSize: 9, height: 1.45, color: AppColors.textSecondary),
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
      ),
    );
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
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
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

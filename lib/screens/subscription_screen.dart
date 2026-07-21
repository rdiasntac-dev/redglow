import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _annual = false;
  bool _subscribed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedMobileBody(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 12),
              const _PlanHero(),
              const SizedBox(height: 14),
              _BillingToggle(
                annual: _annual,
                onChanged: (value) => setState(() => _annual = value),
              ),
              const SizedBox(height: 12),
              _PriceCard(annual: _annual),
              const SizedBox(height: 18),
              Text('O QUE ESTÁ INCLUÍDO', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 9),
              const _BenefitTile(
                icon: Icons.percent_rounded,
                color: AppColors.yellow,
                title: 'Zero comissão por atendimento',
                subtitle: '100% do valor vai para você',
              ),
              const SizedBox(height: 8),
              const _BenefitTile(
                icon: Icons.calendar_month_rounded,
                color: AppColors.green,
                title: 'Agenda completamente livre',
                subtitle: 'Você escolhe dias e horários',
              ),
              const SizedBox(height: 8),
              const _BenefitTile(
                icon: Icons.shield_outlined,
                color: AppColors.route,
                title: 'Segurança garantida',
                subtitle: 'Clientes verificados e central de emergência',
              ),
              const SizedBox(height: 8),
              const _BenefitTile(
                icon: Icons.trending_up_rounded,
                color: AppColors.primary,
                title: 'Visibilidade profissional',
                subtitle: 'Perfil ativo para clientes da sua região',
              ),
              const SizedBox(height: 14),
              const Center(
                child: StatusPill(
                  label: '7 DIAS DE GARANTIA · CANCELE QUANDO QUISER',
                  color: AppColors.green,
                  icon: Icons.verified_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ConstrainedMobileBody(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: GradientButton(
              key: const Key('subscribe-button'),
              label: _subscribed ? 'Perfil profissional ativado!' : 'Assinar e Ativar Perfil',
              icon: _subscribed ? Icons.check_circle_rounded : Icons.workspace_premium_rounded,
              gradient: _subscribed
                  ? const LinearGradient(colors: [Color(0xFF0FBF8B), Color(0xFF0E9F75)])
                  : pinkGradient,
              onPressed: () {
                setState(() => _subscribed = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plano profissional ativado com sucesso.')),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanHero extends StatelessWidget {
  const _PlanHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFFE94AA4), Color(0xFF8A2AC5)]),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .3), blurRadius: 26)],
          ),
          child: const Icon(Icons.workspace_premium_rounded, size: 45, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const StatusPill(label: 'PARA PROFISSIONAIS'),
        const SizedBox(height: 10),
        Text('Plano Profissional\nIlimitado', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        const Text(
          'Parceria justa — você recebe\n100% de cada atendimento.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.annual, required this.onChanged});

  final bool annual;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(4),
      radius: 14,
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Mensal',
              selected: !annual,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Anual · economize 20%',
              selected: annual,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? pinkGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
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

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.annual});

  final bool annual;

  @override
  Widget build(BuildContext context) {
    final price = annual ? '47,90' : '59,90';
    return GlowCard(
      padding: const EdgeInsets.all(16),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5B1A82), Color(0xFF2B1247)],
      ),
      borderColor: AppColors.primary.withValues(alpha: .6),
      boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: .18), blurRadius: 24)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('REDGLOW', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          const Text('Plano Profissional', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('R\$', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
              Text(price, style: const TextStyle(fontSize: 43, height: .95, fontWeight: FontWeight.w900)),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text('/mês', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ),
            ],
          ),
          if (annual)
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text('Cobrança anual de R\$ 574,80', style: TextStyle(fontSize: 8, color: AppColors.green)),
            ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.green.withValues(alpha: .3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.all_inclusive_rounded, color: AppColors.green, size: 21),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Atendimentos ilimitados', style: TextStyle(fontSize: 10, color: AppColors.green, fontWeight: FontWeight.w900)),
                      Text('Sem taxas, sem comissão. Zero.', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      radius: AppRadius.md,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: .12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                Text(subtitle, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 17),
        ],
      ),
    );
  }
}

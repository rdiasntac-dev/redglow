import 'package:flutter/material.dart';

import '../models/reward_catalog.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    return Scaffold(
      body: ConstrainedMobileBody(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REDGLOW PONTOS',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Benefícios locais por atendimentos concluídos',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlowCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCB2DAF), Color(0xFF6F39DE)],
                ),
                borderColor: Colors.transparent,
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SALDO DISPONÍVEL',
                            style: TextStyle(fontSize: 8, color: Colors.white70),
                          ),
                          Text(
                            '${state.points} pontos',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const StatusPill(
                      label: 'BETA',
                      color: AppColors.yellow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const GlowCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_outlined, color: AppColors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Manicure tradicional concluída vale 10 pontos. Pedidos cancelados não pontuam. Nesta fase a troca gera uma reserva de teste, sem entrega ou pagamento real.',
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionTitle(title: 'Extrato de pontos'),
              const SizedBox(height: 9),
              if (state.rewardEligibleBookings.isEmpty &&
                  state.rewardRedemptions.isEmpty)
                const GlowCard(
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long_outlined, color: AppColors.textMuted),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Nenhum lançamento válido. Os pontos aparecerão aqui somente após um atendimento 7.0.8+ ser concluído.',
                          style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                for (final booking in state.rewardEligibleBookings)
                  _PointLedgerCard(
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.green,
                    title: booking.serviceNames.join(' + '),
                    subtitle:
                        'Atendimento concluído · ${_shortDate(booking.completedAt!)}',
                    points: booking.pointsEarned,
                  ),
                for (final redemption in state.rewardRedemptions)
                  _PointLedgerCard(
                    icon: Icons.redeem_outlined,
                    color: AppColors.primary,
                    title: redemption.rewardName,
                    subtitle: 'Reserva beta · ${_shortDate(redemption.createdAt)}',
                    points: -redemption.pointsCost,
                  ),
              ],
              if (state.ignoredLegacyPoints > 0) ...[
                const SizedBox(height: 4),
                GlowCard(
                  color: AppColors.yellow.withValues(alpha: .06),
                  borderColor: AppColors.yellow.withValues(alpha: .35),
                  child: Text(
                    '${state.ignoredLegacyPoints} ponto(s) de registros antigos foram desconsiderados porque não possuem conclusão auditável. Eles permanecem apenas no histórico.',
                    style: const TextStyle(
                      fontSize: 8.5,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const SectionTitle(title: 'Recompensas de parceiros'),
              const SizedBox(height: 9),
              for (final reward in RedGlowRewardCatalog.rewards)
                _RewardCard(reward: reward, state: state),
              if (state.rewardRedemptions.isNotEmpty) ...[
                const SizedBox(height: 18),
                const SectionTitle(title: 'Minhas reservas'),
                const SizedBox(height: 9),
                for (final redemption in state.rewardRedemptions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlowCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  redemption.rewardName,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '${redemption.voucherCode} · aguardando retirada beta',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '-${redemption.pointsCost} pts',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
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

String _shortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

class _PointLedgerCard extends StatelessWidget {
  const _PointLedgerCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.points,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowCard(
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${points > 0 ? '+' : ''}$points pts',
              style: TextStyle(
                color: points > 0 ? AppColors.green : AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCard extends StatefulWidget {
  const _RewardCard({required this.reward, required this.state});

  final RedGlowReward reward;
  final DemoAppState state;

  @override
  State<_RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<_RewardCard> {
  bool _loading = false;

  Future<void> _redeem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar troca beta?'),
        content: Text(
          '${widget.reward.pointsCost} pontos serão usados para reservar ${widget.reward.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            key: const Key('confirm-reward-redemption'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    final voucher = await widget.state.redeemReward(
      rewardId: widget.reward.id,
      rewardName: widget.reward.name,
      partnerName: widget.reward.partnerName,
      pointsCost: widget.reward.pointsCost,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          voucher == null
              ? widget.state.backendError ?? 'Não foi possível reservar.'
              : 'Reserva criada: $voucher',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.state.points >= widget.reward.pointsCost;
    return GlowCard(
      key: Key('reward-${widget.reward.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 118,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.reward.colors),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: 18,
                  top: 15,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white30,
                    size: 34,
                  ),
                ),
                Center(
                  child: Icon(widget.reward.icon, color: Colors.white, size: 56),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reward.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  widget.reward.partnerName,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.reward.description,
                  style: const TextStyle(
                    fontSize: 9,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                GradientButton(
                  key: const Key('redeem-earrings'),
                  label: _loading
                      ? 'Reservando...'
                      : 'Trocar por ${widget.reward.pointsCost} pontos',
                  icon: Icons.redeem_rounded,
                  enabled: enabled && !_loading,
                  onPressed: _redeem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

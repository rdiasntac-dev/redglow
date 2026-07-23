import 'package:flutter/material.dart';

import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key, required this.viewingAsProvider});

  final bool viewingAsProvider;

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final ownScore = viewingAsProvider
        ? state.providerToClientRating
        : state.clientToProviderRating;
    final receivedScore = viewingAsProvider
        ? state.clientToProviderRating
        : state.providerToClientRating;
    final ownTags = viewingAsProvider
        ? state.providerToClientTags
        : state.clientToProviderTags;
    final receivedTags = viewingAsProvider
        ? state.clientToProviderTags
        : state.providerToClientTags;
    final ownComment = viewingAsProvider
        ? state.providerToClientComment
        : state.clientToProviderComment;
    final receivedComment = viewingAsProvider
        ? state.clientToProviderComment
        : state.providerToClientComment;
    final bothCompleted = ownScore > 0 && receivedScore > 0;

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
                          'Avaliações do atendimento',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Notas liberadas após a avaliação mútua',
                          style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.shield_rounded, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 16),
              GlowCard(
                borderColor: AppColors.primary.withValues(alpha: .45),
                child: Row(
                  children: [
                    ProfileAvatar(
                      imageUrl: viewingAsProvider
                          ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=180'
                          : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=180',
                      size: 50,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewingAsProvider ? state.clientName : state.providerName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                          const Text(
                            'Manicure e Pedicure · R\$ 60,00',
                            style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(
                      label: bothCompleted ? 'LIBERADA' : 'PENDENTE',
                      color: bothCompleted ? AppColors.green : AppColors.yellow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ReviewCard(
                key: const Key('own-review-card'),
                title: 'Sua avaliação enviada',
                score: ownScore,
                tags: ownTags,
                comment: ownComment,
                emptyMessage: 'Você ainda não avaliou este atendimento.',
              ),
              const SizedBox(height: 12),
              if (bothCompleted)
                _ReviewCard(
                  key: const Key('received-review-card'),
                  title: viewingAsProvider
                      ? 'Avaliação recebida da cliente'
                      : 'Avaliação recebida da prestadora',
                  score: receivedScore,
                  tags: receivedTags,
                  comment: receivedComment,
                  emptyMessage: 'A outra avaliação ainda não foi enviada.',
                )
              else
                const GlowCard(
                  key: Key('locked-review-card'),
                  borderColor: Color(0xFF4A4050),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_clock_outlined, color: AppColors.yellow),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Avaliação recebida protegida',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'A nota da outra pessoa será revelada somente depois que ambas avaliarem. Isso reduz influência e retaliação.',
                              style: TextStyle(fontSize: 9, height: 1.45, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              const GlowCard(
                color: Color(0xFF15151D),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: AppColors.purple, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Relatos ficam vinculados ao atendimento. Conteúdo ofensivo ou uma ocorrência de segurança poderá ser encaminhado para moderação.',
                        style: TextStyle(fontSize: 9, height: 1.45, color: AppColors.textSecondary),
                      ),
                    ),
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.score,
    required this.tags,
    required this.comment,
    required this.emptyMessage,
    super.key,
  });

  final String title;
  final int score;
  final List<String> tags;
  final String comment;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          if (score == 0)
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
            )
          else ...[
            Row(
              children: [
                for (var star = 1; star <= 5; star++)
                  Icon(
                    star <= score ? Icons.star_rounded : Icons.star_border_rounded,
                    color: star <= score ? AppColors.yellow : AppColors.textMuted,
                    size: 25,
                  ),
                const Spacer(),
                Text(
                  '$score,0',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final tag in tags)
                    StatusPill(label: tag, color: AppColors.purple),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                comment.isEmpty ? 'Nenhum relato escrito foi enviado.' : comment,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.45,
                  color: comment.isEmpty
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                  fontStyle: comment.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

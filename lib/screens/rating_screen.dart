import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final Set<String> _selectedTags = {};
  final _commentController = TextEditingController();
  bool _sent = false;

  static const tags = [
    'Pontual',
    'Caprichosa',
    'Ótima Profissional',
    'Ambiente Limpo',
    'Voltaria sempre',
    'Discreta',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha uma nota de 1 a 5 estrelas.')),
      );
      return;
    }
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return Scaffold(
        body: ConstrainedMobileBody(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.green.withOpacity(.55)),
                        boxShadow: [BoxShadow(color: AppColors.green.withOpacity(.24), blurRadius: 28)],
                      ),
                      child: const Icon(Icons.check_rounded, size: 46, color: AppColors.green),
                    ),
                    const SizedBox(height: 20),
                    Text('Avaliação enviada!', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 7),
                    const Text(
                      'Seu relato ajuda a manter a comunidade REDGLOW segura e confiável.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Voltar ao início',
                      icon: Icons.home_rounded,
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      gradient: const LinearGradient(colors: [Color(0xFF0FBF8B), Color(0xFF0E9F75)]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

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
              const _ProfessionalReviewCard(),
              const SizedBox(height: 18),
              const Center(
                child: Text('Dê uma nota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var star = 1; star <= 5; star++)
                    IconButton(
                      key: Key('rating-star-$star'),
                      onPressed: () => setState(() => _rating = star),
                      icon: Icon(
                        star <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: star <= _rating ? AppColors.yellow : AppColors.textMuted,
                        size: 36,
                      ),
                    ),
                ],
              ),
              Center(
                child: Text(
                  _ratingLabel(_rating),
                  style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 20),
              Text('O QUE SE DESTACOU?', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 9),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return FilterChip(
                    selected: selected,
                    showCheckmark: false,
                    label: Text(tag),
                    selectedColor: AppColors.primary.withOpacity(.17),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) => setState(() {
                      selected ? _selectedTags.remove(tag) : _selectedTags.add(tag);
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Text('RELATO RÁPIDO (OPCIONAL)', style: Theme.of(context).textTheme.labelSmall)),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _commentController,
                    builder: (_, value, __) => Text('${value.text.length}/200', style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              TextField(
                key: const Key('rating-comment'),
                controller: _commentController,
                maxLength: 200,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Conte brevemente como foi a experiência...',
                  counterText: '',
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
              key: const Key('submit-rating'),
              label: 'Enviar Avaliação',
              icon: Icons.send_rounded,
              onPressed: _submit,
            ),
          ),
        ),
      ),
    );
  }
}

String _ratingLabel(int rating) {
  return switch (rating) {
    1 => 'Ruim',
    2 => 'Regular',
    3 => 'Bom',
    4 => 'Excelente',
    5 => 'Incrível ✨',
    _ => 'Toque nas estrelas para avaliar',
  };
}

class _ProfessionalReviewCard extends StatelessWidget {
  const _ProfessionalReviewCard();

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      gradient: const LinearGradient(colors: [Color(0xFF32122F), Color(0xFF221129)]),
      borderColor: AppColors.primary.withOpacity(.45),
      child: const Column(
        children: [
          Text('COMO FOI O ATENDIMENTO?', style: TextStyle(fontSize: 8, color: AppColors.textSecondary, letterSpacing: .4)),
          SizedBox(height: 10),
          ProfileAvatar(
            imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=180',
            size: 74,
            borderColor: AppColors.primary,
          ),
          SizedBox(height: 9),
          Text('Lari (Manicure)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          Text('Manicure Profissional', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          SizedBox(height: 9),
          StatusPill(label: 'Serviço concluído · Manicure e Pedicure', icon: Icons.check_circle_outline_rounded),
        ],
      ),
    );
  }
}

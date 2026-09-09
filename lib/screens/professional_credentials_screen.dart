import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/service_catalog.dart';
import '../services/profile_media_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProfessionalCredentialsScreen extends StatefulWidget {
  const ProfessionalCredentialsScreen({super.key});

  @override
  State<ProfessionalCredentialsScreen> createState() =>
      _ProfessionalCredentialsScreenState();
}

class _ProfessionalCredentialsScreenState
    extends State<ProfessionalCredentialsScreen> {
  final Set<String> _demoSubmitted = {};
  String? _uploadingCategory;
  String? _error;

  Future<void> _upload(
    RedGlowServiceCategory category,
    DemoAppState state,
  ) async {
    if (state.isDemoSession) {
      setState(() => _demoSubmitted.add(category.label));
      return;
    }
    if (Firebase.apps.isEmpty || FirebaseAuth.instance.currentUser == null) {
      setState(() => _error = 'Sua sessão expirou. Entre novamente.');
      return;
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      _uploadingCategory = category.label;
      _error = null;
    });
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1800,
      );
      if (file == null) {
        if (mounted) setState(() => _uploadingCategory = null);
        return;
      }
      final bytes = await file.readAsBytes();
      final url = await ProfileMediaService().uploadProfessionalCredential(
        uid: uid,
        categoryId: category.id,
        bytes: bytes,
      );
      await FirebaseFirestore.instance
          .collection('professionalCredentials')
          .doc(uid)
          .set({
        'uid': uid,
        'documents': {
          category.id: {
            'category': category.label,
            'fileName': file.name,
            'downloadUrl': url,
            'status': 'pending',
            'uploadedAt': FieldValue.serverTimestamp(),
          },
        },
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Comprovante de ${category.label} enviado para análise.',
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.code == 'object-not-found'
            ? 'O armazenamento de documentos ainda não foi ativado.'
            : 'Não foi possível enviar o comprovante (${error.code}).';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível enviar o comprovante agora.';
      });
    } finally {
      if (mounted) setState(() => _uploadingCategory = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final selectedLabels = state.providerSpecialties;
    final selectedCategories = RedGlowServiceCatalog.categories
        .where((category) => selectedLabels.contains(category.label))
        .toList(growable: false);

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
                          'ID profissional',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Identidade e comprovação das especializações',
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
              const GlowCard(
                borderColor: Color(0xFF5A2450),
                color: Color(0xFF1F101C),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cada nicho informado exige comprovante. O envio não aprova automaticamente o perfil: a equipe REDGLOW fará análise manual para reduzir fraudes.',
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
              const SizedBox(height: 12),
              if (selectedCategories.isEmpty)
                const GlowCard(
                  child: Text(
                    'Selecione primeiro os nichos e serviços do seu perfil profissional.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                _CredentialsList(
                  categories: selectedCategories,
                  state: state,
                  demoSubmitted: _demoSubmitted,
                  uploadingCategory: _uploadingCategory,
                  onUpload: _upload,
                ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.redAccent,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const Text(
                'Arquivos visíveis somente para a titular e para a equipe autorizada de validação. O certificado não será exibido publicamente.',
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

class _CredentialsList extends StatelessWidget {
  const _CredentialsList({
    required this.categories,
    required this.state,
    required this.demoSubmitted,
    required this.uploadingCategory,
    required this.onUpload,
  });

  final List<RedGlowServiceCategory> categories;
  final DemoAppState state;
  final Set<String> demoSubmitted;
  final String? uploadingCategory;
  final void Function(RedGlowServiceCategory, DemoAppState) onUpload;

  @override
  Widget build(BuildContext context) {
    if (state.isDemoSession ||
        Firebase.apps.isEmpty ||
        FirebaseAuth.instance.currentUser == null) {
      return Column(
        children: [
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _CredentialCard(
                category: category,
                status: demoSubmitted.contains(category.label)
                    ? 'pending'
                    : 'missing',
                loading: uploadingCategory == category.label,
                onUpload: () => onUpload(category, state),
              ),
            ),
        ],
      );
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('professionalCredentials')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final rawDocuments = snapshot.data?.data()?['documents'];
        final documents = rawDocuments is Map
            ? Map<String, dynamic>.from(rawDocuments)
            : const <String, dynamic>{};
        return Column(
          children: [
            for (final category in categories)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _CredentialCard(
                  category: category,
                  status: (documents[category.id] is Map
                          ? Map<String, dynamic>.from(
                              documents[category.id] as Map,
                            )['status']
                          : null) as String? ??
                      'missing',
                  loading: uploadingCategory == category.label,
                  onUpload: () => onUpload(category, state),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CredentialCard extends StatelessWidget {
  const _CredentialCard({
    required this.category,
    required this.status,
    required this.loading,
    required this.onUpload,
  });

  final RedGlowServiceCategory category;
  final String status;
  final bool loading;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final submitted = status != 'missing';
    final color = switch (status) {
      'approved' => AppColors.green,
      'rejected' => Colors.redAccent,
      'pending' => AppColors.yellow,
      _ => AppColors.textMuted,
    };
    final label = switch (status) {
      'approved' => 'APROVADO',
      'rejected' => 'REVISAR',
      'pending' => 'EM ANÁLISE',
      _ => 'PENDENTE',
    };
    return GlowCard(
      borderColor: color.withValues(alpha: .42),
      child: Row(
        children: [
          Icon(
            submitted
                ? Icons.description_outlined
                : Icons.upload_file_outlined,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  submitted
                      ? 'Comprovante recebido pela REDGLOW'
                      : 'Envie certificado, diploma ou declaração',
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (loading)
            const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton(
              onPressed: onUpload,
              child: Text(submitted ? 'Substituir' : 'Enviar'),
            ),
          StatusPill(label: label, color: color),
        ],
      ),
    );
  }
}

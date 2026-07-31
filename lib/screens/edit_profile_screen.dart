import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_role.dart';
import '../services/profile_media_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  bool _uploadingPhoto = false;
  String _photoUrl = '';
  Uint8List? _photoBytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final state = DemoAppScope.of(context, listen: false);
    final isProvider = widget.role == UserRole.provider;
    _nameController.text = state.accountName ??
        (state.isDemoSession
            ? isProvider
                ? 'Lari (Manicure)'
                : 'Cliente REDGLOW'
            : '');
    _phoneController.text =
        state.accountPhone ?? (state.isDemoSession ? '(41) 99999-9999' : '');
    _photoUrl = state.profilePhotoUrl;
    _initialized = true;
  }

  Future<void> _pickPhoto() async {
    final state = DemoAppScope.of(context, listen: false);
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _photoBytes = bytes;
      _uploadingPhoto = !state.isDemoSession;
    });
    if (state.isDemoSession) {
      setState(() => _uploadingPhoto = false);
      return;
    }
    final uid = state.currentUserId;
    if (uid == null) {
      setState(() => _uploadingPhoto = false);
      return;
    }
    try {
      final url = await ProfileMediaService().uploadProfilePhoto(
        uid: uid,
        bytes: bytes,
      );
      final saved = await state.updateProfilePhoto(url);
      if (!mounted) return;
      if (!saved) {
        throw StateError('Não foi possível vincular a foto ao perfil.');
      }
      setState(() {
        _photoUrl = url;
        _uploadingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível enviar a foto. Verifique o armazenamento do Firebase.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final state = DemoAppScope.of(context, listen: false);
    final succeeded = await state.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.backendError ?? 'Não foi possível salvar.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final isProvider = widget.role == UserRole.provider;
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
                  Expanded(
                    child: Text(
                      isProvider ? 'Perfil profissional' : 'Editar perfil',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: InkWell(
                  key: const Key('profile-photo-picker'),
                  onTap: _uploadingPhoto ? null : _pickPhoto,
                  customBorder: const CircleBorder(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _photoBytes != null
                              ? Image.memory(_photoBytes!, fit: BoxFit.cover)
                              : Image.network(
                                  _photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    isProvider
                                        ? Icons.badge_outlined
                                        : Icons.person_outline_rounded,
                                    color: AppColors.textSecondary,
                                    size: 34,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: -3,
                        bottom: -3,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: _uploadingPhoto
                              ? const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 15,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                state.isDemoSession
                    ? 'A foto escolhida será apenas uma prévia nesta demonstração.'
                    : 'Toque na foto para escolher uma imagem da galeria.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 8, color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(isProvider ? 'NOME PROFISSIONAL' : 'NOME'),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('profile-name-field'),
                      controller: _nameController,
                      maxLength: 60,
                      decoration: const InputDecoration(
                        hintText: 'Como deseja aparecer no REDGLOW',
                        counterText: '',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 13),
                    const _FieldLabel('CELULAR'),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('profile-phone-field'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        hintText: '(41) 99999-9999',
                        counterText: '',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                      ),
                    ),
                    if (isProvider) ...[
                      const SizedBox(height: 13),
                      const GlowCard(
                        padding: EdgeInsets.all(10),
                        color: AppColors.surfaceRaised,
                        child: Row(
                          children: [
                            Icon(
                              Icons.design_services_outlined,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Nichos, procedimentos e preços individuais são configurados em “Serviços que realizo”.',
                                style: TextStyle(
                                  fontSize: 8,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (state.isDemoSession) ...[
                const SizedBox(height: 10),
                const GlowCard(
                  borderColor: Color(0xFF5E4D24),
                  color: Color(0xFF211D10),
                  child: Row(
                    children: [
                      Icon(Icons.science_outlined, color: AppColors.yellow),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Na demonstração, as alterações permanecem apenas durante a sessão atual.',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              GradientButton(
                key: const Key('save-profile'),
                label: _saving ? 'Salvando...' : 'Salvar alterações',
                icon: Icons.check_rounded,
                enabled: !_saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.labelSmall);
  }
}

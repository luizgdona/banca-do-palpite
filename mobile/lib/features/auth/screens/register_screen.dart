import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bdp_logo.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (!mounted) return;
    final state = ref.read(authProvider).valueOrNull;
    if (state?.status == AuthStatus.authenticated) {
      context.go('/home');
    } else if (state?.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state!.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        leading: BackButton(
          color: AppColors.offWhite,
          onPressed: () => context.pop(),
        ),
        title: const Text('CRIAR CONTA'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.sheetPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.gapBase,
              const Center(child: BdpHexLogo(size: 64)),
              AppSpacing.gapXxl,
              Text('Crie sua conta', style: AppTextStyles.screenTitle),
              AppSpacing.gapSm,
              Text(
                'Junte-se ao bolão dos seus amigos.',
                style: AppTextStyles.bodySm,
              ),
              AppSpacing.gapXxl,
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppColors.greenLight),
                ),
                validator: (v) =>
                    v == null || v.trim().length < 2 ? 'Nome muito curto' : null,
              ),
              AppSpacing.gapBase,
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppColors.greenLight),
                ),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Email inválido' : null,
              ),
              AppSpacing.gapBase,
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.greenLight),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.mutedDark,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  helperText: 'Mínimo de 8 caracteres',
                ),
                validator: (v) => v == null || v.length < 8
                    ? 'Senha deve ter ao menos 8 caracteres'
                    : null,
              ),
              AppSpacing.gapXxl,
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.green,
                        ),
                      )
                    : const Text('CRIAR CONTA'),
              ),
              AppSpacing.gapBase,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Já tem conta? ', style: AppTextStyles.bodySm),
                  GestureDetector(
                    onTap: () => context.pushReplacement('/login'),
                    child: Text(
                      'Entrar',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.amber,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

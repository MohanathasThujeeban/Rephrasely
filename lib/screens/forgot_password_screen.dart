import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    (AppSizes.lg * 2),
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Header
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.xl),
                            Container(
                              padding: const EdgeInsets.all(AppSizes.lg),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _emailSent
                                    ? Icons.mark_email_read
                                    : Icons.lock_reset,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSizes.lg),
                            Text(
                              _emailSent
                                  ? 'Check Your Email'
                                  : 'Forgot Password?',
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              _emailSent
                                  ? 'We\'ve sent a password reset link to\n${_emailController.text}'
                                  : 'Enter your email address and we\'ll send\nyou a link to reset your password',
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xxl),

                    // Content
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _emailSent
                              ? _buildSuccessContent()
                              : _buildFormContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: CustomTextField(
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: _validateEmail,
          ),
        ),
        const SizedBox(height: AppSizes.xl),

        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Send Reset Link',
                    onPressed: () => _handleSendResetEmail(context),
                    isLoading: authProvider.isLoading,
                  ),
                ),
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: AppSizes.md),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: AppSizes.iconSize,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),

        const Spacer(),

        // Back to Login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Remember your password? ', style: AppTextStyles.bodyMedium),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Sign In',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.largeBorderRadius),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Email Sent Successfully!',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Please check your inbox and click the reset link to create a new password.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.xl),

        // Resend email button
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Resend Email',
            onPressed: () => _handleResendEmail(context),
            isOutlined: true,
            backgroundColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // Back to login
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Back to Sign In',
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: AppColors.primary,
          ),
        ),

        const Spacer(),

        // Didn't receive email help
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                'Didn\'t receive the email?',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                '• Check your spam folder\n• Make sure the email address is correct\n• Wait a few minutes for delivery',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleSendResetEmail(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text,
    );

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    }
  }

  Future<void> _handleResendEmail(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reset email sent again!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
      );
    }
  }
}

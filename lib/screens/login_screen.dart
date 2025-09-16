import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/rephrasely_logo.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    _passwordController.dispose();
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
                            const SizedBox(height: AppSizes.lg),
                            const RephraselyLogo(size: 80, animate: true),
                            const SizedBox(height: AppSizes.lg),
                            Text(
                              'Welcome Back!',
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              'Sign in to continue to your account',
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Form
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Social Login Buttons
                              _buildSocialButtons(),
                              const SizedBox(height: AppSizes.lg),

                              // Divider
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(color: AppColors.border),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.md,
                                    ),
                                    child: Text(
                                      'Or continue with email',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(color: AppColors.border),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.lg),

                              // Email/Password Form
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      label: 'Email',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email_outlined,
                                      validator: _validateEmail,
                                    ),
                                    const SizedBox(height: AppSizes.md),
                                    CustomTextField(
                                      label: 'Password',
                                      controller: _passwordController,
                                      isPassword: true,
                                      prefixIcon: Icons.lock_outline,
                                      validator: _validatePassword,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      _navigateToForgotPassword(context),
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSizes.lg),

                              // Login Button
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: CustomButton(
                                          text: 'Sign In',
                                          onPressed: () =>
                                              _handleLogin(context),
                                          isLoading: authProvider.isLoading,
                                        ),
                                      ),
                                      if (authProvider.errorMessage !=
                                          null) ...[
                                        const SizedBox(height: AppSizes.md),
                                        Container(
                                          padding: const EdgeInsets.all(
                                            AppSizes.md,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppSizes.borderRadius,
                                            ),
                                            border: Border.all(
                                              color: AppColors.error
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: AppColors.error,
                                                size: AppSizes.iconSize,
                                              ),
                                              const SizedBox(
                                                width: AppSizes.sm,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  authProvider.errorMessage!,
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(
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

                              // Register Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don\'t have an account? ',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _navigateToRegister(context),
                                    child: Text(
                                      'Sign Up',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Widget _buildSocialButtons() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () => _handleGoogleSignIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.buttonBorderRadius,
                    ),
                  ),
                  minimumSize: const Size(
                    double.infinity,
                    AppSizes.buttonHeight,
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: AppSizes.iconSize,
                            height: AppSizes.iconSize,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/icons/google.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Text(
                            'Continue with Google',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () => _handleFacebookSignIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.facebookBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.buttonBorderRadius,
                    ),
                  ),
                  minimumSize: const Size(
                    double.infinity,
                    AppSizes.buttonHeight,
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.facebook,
                            size: AppSizes.iconSize,
                            color: Colors.white,
                          ),
                          const SizedBox(width: AppSizes.md),
                          Text(
                            'Continue with Facebook',
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _handleFacebookSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.signInWithFacebook();

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToForgotPassword(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ForgotPasswordScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

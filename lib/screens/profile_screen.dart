import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventaccess_app/widgets/client_number_header.dart';
import 'package:eventaccess_app/services/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> user;
  bool _isLoading = true;
  bool _isUpdatingEmail = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1)); // Delay obligatorio
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1)); // Delay obligatorio
  }

  Future<void> _editEmail() async {
    final controller = TextEditingController(text: user['email']);

    final newEmail = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Editar correo electrónico',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Nuevo correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final email = controller.text.trim();
                            if (_validateEmail(email) &&
                                email != user['email']) {
                              await Future.delayed(const Duration(seconds: 1)); // Delay obligatorio
                              setState(() => _isUpdatingEmail = true);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pop(context, email);
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error en el email')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (newEmail != null) {
      // Delay obligatorio de 1 segundo para mostrar al usuario que su petición está siendo procesada
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() {
        user['email'] = newEmail;
        _isUpdatingEmail = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final theme = Theme.of(context);
    final isDark = context.select<ThemeProvider, bool>((p) => p.isDark);

    // Código hardcodeado para mostrar vista
    user = {
      'clientNumber': 'A123456789',
      'fullName': 'María González López',
      'email': 'maria.gonzalez@email.com',
      'status': 'Activo',
      'balance': 250.75,
    };

    return PopScope(
      canPop: !_isUpdatingEmail,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade700,
          title: const Text('Mi perfil'),
        ),
        body: AbsorbPointer(
          absorbing: _isUpdatingEmail,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: Colors.green,
            child: Column(
              children: [
                const ClientNumberHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      AbsorbPointer(
                        absorbing: _isUpdatingEmail,
                        child: Opacity(
                          opacity: _isUpdatingEmail ? 0.5 : 1.0,
                          child: Card(
                            elevation: 0,
                            color: theme.colorScheme.surface.withAlpha(230),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: theme.colorScheme.outline.withAlpha(50),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: const Text('Nombre completo'),
                                  subtitle: Text(user['fullName'] as String),
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text('Correo electrónico'),
                                  subtitle: _isUpdatingEmail
                                      ? const Row(
                                          children: [
                                            SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                            SizedBox(width: 8),
                                            Text('Actualizando...'),
                                          ],
                                        )
                                      : Text(user['email'] as String),
                                  trailing: _isUpdatingEmail
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : IconButton.outlined(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.orange,
                                          ),
                                          onPressed: _editEmail,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 32),
                      AbsorbPointer(
                        absorbing: _isUpdatingEmail,
                        child: Opacity(
                          opacity: _isUpdatingEmail ? 0.5 : 1.0,
                          child: Card(
                            elevation: 0,
                            color: theme.colorScheme.surface.withAlpha(230),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: theme.colorScheme.outline.withAlpha(50),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                color: theme.colorScheme.primary,
                              ),
                              title: const Text("Modo oscuro"),
                              trailing: Switch(
                                value: isDark,
                                onChanged: (val) async {
                                  final themeProvider = context.read<ThemeProvider>();
                                  await themeProvider.setDark(val);
                                  await Future.delayed(const Duration(seconds: 1)); // Delay obligatorio
                                },
                                activeThumbColor: Colors.green,
                                activeTrackColor: Colors.green.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
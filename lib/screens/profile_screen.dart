import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventaccess_app/widgets/client_number_header.dart';
import 'package:eventaccess_app/services/theme_provider.dart';
import 'package:eventaccess_app/services/data_provider.dart';
// ignore: unused_import
import 'package:eventaccess_app/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUpdatingEmail = false;

  @override
  void initState() {
    super.initState();
    // No need for _loadData since DataProvider handles loading
  }

  Future<void> _refreshData() async {
    final dataProvider = context.read<DataProvider>();
    await dataProvider.refreshAllData();
  }

  Future<void> _editEmail() async {
    final dataProvider = context.read<DataProvider>();
    final user = dataProvider.user;
    if (user == null) return;
    final controller = TextEditingController(text: user.email);

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
                                email != user.email) {
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
        // TODO: Implementar API call para actualizar email
        // Por ahora, solo mostrar mensaje
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        setState(() {
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
    final dataProvider = context.watch<DataProvider>();
    final user = dataProvider.user;
    final isLoading = dataProvider.isLoading;

    if (isLoading || user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final theme = Theme.of(context);
    final isDark = context.select<ThemeProvider, bool>((p) => p.isDark);

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
                                   subtitle: Text(user.fullName),
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
                                       : Text(user.email),
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
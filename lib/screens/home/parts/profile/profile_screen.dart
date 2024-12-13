import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasksync/services/auth_service.dart';
import 'package:tasksync/screens/home/parts/profile/dialogs/delete_account_dialog.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService authService;

  const ProfileScreen({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const Icon(
                Icons.account_circle,
                size: 100,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: Card(
                  elevation: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: authService.currentUser!.email!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email, size: 24),
                    label: Text(
                      authService.currentUser!.email!,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: Card(
                  elevation: 2,
                  child: ElevatedButton.icon(
                    onPressed: authService.signOut,
                    icon: const Icon(Icons.logout, size: 24),
                    label: const Text(
                      'Sign Out',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final confirmed = await DeleteAccountDialog.show(context);

                  if (confirmed == true) {
                    try {
                      await authService.deleteAccount();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting account: $e'),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

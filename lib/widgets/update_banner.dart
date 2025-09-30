import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/update_provider.dart';
import 'update_dialog.dart';

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateProvider>(
      builder: (context, updateProvider, child) {
        if (!updateProvider.hasUpdate) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.system_update, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Update Available',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Version ${updateProvider.availableUpdate?.version} is ready',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const UpdateDialog(),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                child: const Text('View'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () {
                  updateProvider.dismissUpdate();
                },
                tooltip: 'Dismiss',
              ),
            ],
          ),
        );
      },
    );
  }
}

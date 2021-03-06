import 'package:flutter/material.dart';
import 'package:flutter_identity_platform_mfa/authenticator.dart';
import 'package:flutter_identity_platform_mfa/page/mfa_enrollmenet_page.dart';
import 'package:flutter_identity_platform_mfa/scaffold_messenger_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tsuruo_kit/widgets/barrier/progress_controller.dart';

import '../auth_repository.dart';
import '../model/model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authenticator).value;
    // signOut時のケア
    if (user == null) {
      return const Scaffold();
    }

    final values = <String, String?>{
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'emailVerified': user.emailVerified.toString(),
      'lastSignInTime': user.metadata.lastSignInTime.toString(),
      'providerId': user.providerData.first.providerId,
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: values.entries.toList().length,
            itemBuilder: (context, index) {
              final value = values.entries.toList()[index];
              return _ListTile(
                title: value.key,
                value: value.value,
              );
            },
            separatorBuilder: (context, _index) => const Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final res = await ref
                        .read(progressController)
                        .executeWithProgress(
                          () =>
                              ref.read(authRepository).sendEmailVerification(),
                        );
                    final messenger =
                        ref.read(scaffoldMessengerProvider).currentState!;
                    if (res.type.success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content:
                              Text('Send verification email successfully.'),
                        ),
                      );
                      return;
                    }
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(res.exception!.code),
                      ),
                    );
                  },
                  child: const Text('Email Verify'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => const MFAEnrollmentPage(),
                      fullscreenDialog: true,
                    ),
                  ),
                  child: const Text('MFA Enrollment'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(progressController).executeWithProgress(
                          () => ref.read(authRepository).reload(),
                        );
                  },
                  child: const Text('Reload'),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(progressController).executeWithProgress(
                    () => ref.read(authRepository).signOut(),
                  );
            },
            child: const Text('Sign out'),
          )
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(title),
      trailing: Text(
        value ?? '---',
        style: theme.textTheme.bodyText2!.copyWith(
          color: value == null ? theme.disabledColor : colorScheme.primary,
        ),
      ),
    );
  }
}

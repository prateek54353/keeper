import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'aboutKeeperTitleHero',
          child: Material(
            color: Colors.transparent,
            child: const Text('About Keeper'),
          ),
        ),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final packageInfo = snapshot.data!;
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.note_alt, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Keeper',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Center(
                child: Text(
                  'Version ${packageInfo.version} (${packageInfo.buildNumber})',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                onTap: () => _showPrivacyPolicy(context),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of Service'),
                onTap: () => _showTermsOfService(context),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Open Source Licenses'),
                onTap: () => _showLicenses(context),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Keeper is a secure note-taking app that helps you organize your thoughts and ideas. Your data is encrypted and stored securely in the cloud.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Collection and Usage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• We only collect the data you explicitly provide (notes, images, files)\n'
                '• Your data is stored securely in Firebase\n'
                '• We use Google Sign-In for authentication\n'
                '• We do not share your data with third parties\n'
                '• You can delete your data at any time',
              ),
              SizedBox(height: 16),
              Text(
                'Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• All data is encrypted in transit\n'
                '• Firebase provides secure data storage\n'
                '• Your Google account credentials are never stored\n'
                '• You can enable/disable sync at any time',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usage Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• You must have a valid Google account to use this app\n'
                '• You are responsible for maintaining the security of your account\n'
                '• You must not use the app for illegal purposes\n'
                '• We reserve the right to terminate access for violations',
              ),
              SizedBox(height: 16),
              Text(
                'Disclaimer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• The app is provided "as is" without warranties\n'
                '• We are not responsible for lost or corrupted data\n'
                '• We may update these terms at any time\n'
                '• Continued use means acceptance of changes',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Keeper',
      applicationVersion: '1.0.0',
    );
  }
} 
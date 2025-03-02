
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

import 'amplifyconfiguration.dart';
import 'main.dart';

class AmplifyManager {


  static Future<void> configureAmplify() async {
    final auth = AmplifyAuthCognito(
      // FIXME: In your app, make sure to remove this line and set up
      /// Keychain Sharing in Xcode as described in the docs:
      /// https://docs.amplify.aws/lib/project-setup/platform-setup/q/platform/flutter/#enable-keychain
      secureStorageFactory: AmplifySecureStorage.factoryFrom(
        macOSOptions:
        // ignore: invalid_use_of_visible_for_testing_member
        MacOSSecureStorageOptions(useDataProtection: false),
      ),
    );
    final storage = AmplifyStorageS3();

    try {
      await Amplify.addPlugins([auth, storage]);
      await Amplify.configure(amplifyconfig);
      customLogger.debug('Successfully configured Amplify');
    } on Exception catch (error) {
      customLogger.error('Something went wrong configuring Amplify: $error');
    }
  }
}

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import 'cache.dart';
import 'main.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StorageItem> list = [];
  var imageUrl = '';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _listAllPrivateFiles();
  }

  // sign out of the app
  Future<void> _signOut() async {
    try {
      await Amplify.Auth.signOut();
      customLogger.debug('Signed out');
    } on AuthException catch (e) {
      customLogger.error('Could not sign out - ${e.message}');
    }
  }

  // check if the user is signed in
  Future<void> _checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      customLogger.debug('Signed in: ${session.isSignedIn}');
    } on AuthException catch (e) {
      customLogger.error('Could not check auth status - ${e.message}');
    }
  }

  Future<void> confirmSignUp(String username, String confirmationCode) async {
    try {
      SignUpResult result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
      print('Confirmation successful: ${result.isSignUpComplete}');
    } catch (e) {
      print('Confirmation failed: $e');
    }
  }


  // upload a file to the S3 bucket
  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withReadStream: true,
      withData: false,
    );

    if (result == null) {
      customLogger.debug('No file selected');
      return;
    }

    final platformFile = result.files.single;

    try {
      await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(
          platformFile.readStream!,
          size: platformFile.size,
        ),
        path: StoragePath.fromString('private/${platformFile.name}'),
        onProgress: (p) =>
            customLogger.debug('Uploading: ${p.transferredBytes}/${p.totalBytes}'),
      ).result;
      await _listAllPrivateFiles();
    } on StorageException catch (e) {
      customLogger.error('Error uploading file - ${e.message}');
    }
  }

  // list all files in the S3 bucket
  Future<void> _listAllPrivateFiles() async {
    try {
      final result = await Amplify.Storage.list(
        path: const StoragePath.fromString('private/'),
        options: const StorageListOptions(
          pluginOptions: S3ListPluginOptions.listAll(),
        ),
      ).result;
      setState(() {
        list = result.items;
      });

      // 각 파일의 URL을 미리 가져옴
      for (var item in list) {
        _fetchPreviewUrl(item.path);
      }
    } on StorageException catch (e) {
      customLogger.error('List error - ${e.message}');
    }
  }

  // download file on mobile
  Future<void> downloadFileMobile(String path) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final filepath = '${documentsDir.path}/$path';
    try {
      await Amplify.Storage.downloadFile(
        path: StoragePath.fromString(path),
        localFile: AWSFile.fromPath(filepath),
        onProgress: (p0) => customLogger
            .debug('Progress: ${(p0.transferredBytes / p0.totalBytes) * 100}%'),
      ).result;
      await _listAllPrivateFiles();
    } on StorageException catch (e) {
      customLogger.error('Download error - ${e.message}');
    }
  }

  // download file on web
  Future<void> downloadFileWeb(String path) async {
    try {
      await Amplify.Storage.downloadFile(
        path: StoragePath.fromString(path),
        localFile: AWSFile.fromPath(path),
        onProgress: (p0) => customLogger
            .debug('Progress: ${(p0.transferredBytes / p0.totalBytes) * 100}%'),
      ).result;
      await _listAllPrivateFiles();
    } on StorageException catch (e) {
      customLogger.error('Download error - ${e.message}');
    }
  }

  // delete file from S3 bucket
  Future<void> removeFile(String path) async {
    try {
      await Amplify.Storage.remove(
        path: StoragePath.fromString(path),
      ).result;
      setState(() {
        // set the imageUrl to empty if the deleted file is the one being displayed
        imageUrl = '';
      });
      await _listAllPrivateFiles();
    } on StorageException catch (e) {
      customLogger.error('Delete error - ${e.message}');
    }
  }

  Future<void> _fetchPreviewUrl(String path) async {
    try {
      final result = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(path),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            validateObjectExistence: true,
            expiresIn: Duration(minutes: 1),
          ),
        ),
      ).result;

      // 메타데이터 및 태그 가져오기
      final properties = await Amplify.Storage.getProperties(
        path: StoragePath.fromString(path),
      ).result;

      print(properties);

      setState(() {
        imageUrls[path] = result.url.toString();
        CustomCacheManager.preloadImage(context, result.url.toString());
      });
    } on StorageException catch (e) {
      customLogger.error('Get URL error - ${e.message}');
    }
  }

  // get the url of a file in the S3 bucket
  Future<String> getUrl(String path) async {
    try {
      final result = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(path),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            validateObjectExistence: true,
            expiresIn: Duration(minutes: 1),
          ),
        ),
      ).result;
      setState(() {
        imageUrl = result.url.toString();
      });
      return result.url.toString();
    } on StorageException catch (e) {
      customLogger.error('Get URL error - ${e.message}');
      rethrow;
    }
  }
  Map<String, String> imageUrls = {}; // S3에서 불러온 이미지 URL을 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S3 Storage - Preview Grid'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3열 그리드
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final previewUrl = imageUrls[item.path] ?? '';

            return GestureDetector(
              onTap: () async {
                // String goto = await getUrl(item.path);
                context.pushNamed('fullsize', queryParameters: {'goto': previewUrl, 'path': item.path});
              },
              child: Stack(
                children: [
                  // 이미지 미리보기 (캐시 적용)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: previewUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: previewUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                    )
                        : Container(color: Colors.grey.shade300),
                  ),

                  // 삭제 버튼
                  // Positioned(
                  //   top: 4,
                  //   right: 4,
                  //   child: GestureDetector(
                  //     onTap: () => removeFile(item.path),
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Colors.red.withOpacity(0.7),
                  //       ),
                  //       padding: const EdgeInsets.all(4),
                  //       child: const Icon(Icons.close, color: Colors.white, size: 16),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ),

      // 업로드 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        child: const Icon(Icons.upload),
      ),
    );
  }
}
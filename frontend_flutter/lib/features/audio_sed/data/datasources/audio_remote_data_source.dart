import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/network/api_client.dart';
import '../models/analysis_result_model.dart';

abstract class AudioRemoteDataSource {
  Future<List<String>> getSamples();

  Future<String> downloadSample(String filename);

  Future<AnalysisResultModel> analyzeAudio({
    required String filePath,
    required String mode,
  });
}

class AudioRemoteDataSourceImpl implements AudioRemoteDataSource {
  final ApiClient client;

  AudioRemoteDataSourceImpl({required this.client});

  @override
  Future<List<String>> getSamples() async {
    final response = await client.get('/api/samples');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((item) => item as String).toList();
    } else {
      throw Exception('Failed to get samples');
    }
  }

  @override
  Future<String> downloadSample(String filename) async {
    final tempDir = await getTemporaryDirectory();
    final localPath = '${tempDir.path}/$filename';
    final response = await client.dio.download('/api/samples/$filename', localPath);
    if (response.statusCode == 200) {
      return localPath;
    } else {
      throw Exception('Failed to download sample');
    }
  }

  @override
  Future<AnalysisResultModel> analyzeAudio({
    required String filePath,
    required String mode,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await client.post(
      '/api/analyze?mode=$mode',
      data: formData,
    );

    if (response.statusCode == 200) {
      return AnalysisResultModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Audio analysis failed');
    }
  }
}


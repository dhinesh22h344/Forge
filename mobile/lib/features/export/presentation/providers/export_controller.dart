import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/export_repository_impl.dart';

class ExportController {
  ExportController(this._ref);
  final Ref _ref;

  /// Fetches the full backup JSON, writes it to a temp file, and hands it to
  /// the OS share sheet — the user picks where it actually lands (Files,
  /// Drive, email, AirDrop, ...), so this never assumes a destination.
  Future<Failure?> exportToFile() async {
    final repository = _ref.read(exportRepositoryProvider);
    final result = await repository.export();
    return result.when(
      success: (payload) async {
        final dir = await getTemporaryDirectory();
        final filename = 'forge-backup-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
        final file = File('${dir.path}/$filename');
        await file.writeAsString(jsonEncode(payload));
        await Share.shareXFiles([XFile(file.path)], text: 'Forge backup');
        return null;
      },
      failure: (failure) => failure,
    );
  }

  /// Lets the user pick a previously exported `.json` file and restores it.
  /// Returns null both on success AND on a plain user-cancelled picker —
  /// only a real failure from the server is surfaced.
  Future<Failure?> importFromFile() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    final path = picked?.files.single.path;
    if (path == null) return null;

    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
    } on FormatException {
      return const ValidationFailure("That file doesn't look like a Forge backup");
    }

    final repository = _ref.read(exportRepositoryProvider);
    final result = await repository.importJson(payload);
    return result.when(success: (_) => null, failure: (failure) => failure);
  }
}

final exportControllerProvider = Provider<ExportController>((ref) => ExportController(ref));

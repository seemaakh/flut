import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/providers/api_providers.dart';

class BatchOption {
  final String id;
  final String name;

  const BatchOption({required this.id, required this.name});

  factory BatchOption.fromJson(Map<String, dynamic> json) {
    return BatchOption(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['batchName'] ?? json['name'] ?? '').toString(),
    );
  }
}

final batchesProvider = FutureProvider<List<BatchOption>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get<Map<String, dynamic>>(ApiEndpoints.batches);
  final data = (res.data?['data'] as List?) ?? const [];
  return data
      .whereType<Map>()
      .map((e) => BatchOption.fromJson(e.cast<String, dynamic>()))
      .toList();
});

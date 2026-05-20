import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:webcrypto/webcrypto.dart';

part 'created_group.freezed.dart';

/// Returned by [AnonaccountGroups.createGroup]. Contains the live
/// `AesGcmSecretKey` because the caller just generated it locally —
/// no need to round-trip through the server.
///
/// Not JSON-serializable: [groupDataKey] is a runtime handle.
/// Consumers persist the JWK form (`exportJsonWebKey`) themselves.
@freezed
class CreatedGroup with _$CreatedGroup {
  const factory CreatedGroup({
    required String groupId,
    required String displayName,
    required AesGcmSecretKey groupDataKey,
    required DateTime createdAt,
  }) = _CreatedGroup;
}

/// A ciphertext together with the generation of the secret inside it.
///
/// Exists so that the pair travels together: a wrapped copy whose
/// generation is unknown cannot be re-wrapped after a rotation.
class WrappedCopy {
  const WrappedCopy({required this.ciphertext, required this.keyEpoch});
  final String ciphertext;
  final int keyEpoch;
}

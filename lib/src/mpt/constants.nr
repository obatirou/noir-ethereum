/// Maximum length (in bytes) of a node in the Merkle Patricia Tree.
///
/// This value is derived from the maximum possible size of a branch node,
/// which is the largest node type in the MPT structure.
///
/// The value 532 is calculated as follows:
///
/// For a branch node (maximum case):
/// - 16 child pointers (each a 32-byte hash)
/// - Each hash has an RLP header of 1 byte
/// - The list of 16 hashes has an RLP header of 3 bytes
/// - An empty string value with RLP header of 1 byte
/// - Total: 3 + (16 * (1 + 32)) + 1 = 532 bytes
///
/// For an extension node (maximum case):
/// - A prefixed key part (maximum 495 bytes)
/// - The key has an RLP header of 1 byte
/// - The key prefix has an RLP header of 2 bytes
/// - A 32-byte hash with RLP header of 1 byte
/// - Total: 1 + (2 + (1 + 495)) + (1 + 32) = 532 bytes
pub global MAX_NODE_LEN: u32 = 532;

/// Maximum number of fields that can be present in any MPT node.
/// This value is used to validate node structure and ensure proper serialization.
pub global MAX_NODE_FIELDS: u32 = 17;

/// Number of fields in a branch node of the MPT.
/// A branch node contains 16 child pointers (one for each hex character)
/// plus one value field, totaling 17 fields.
pub global BRANCH_NODE_NUM_FIELDS: u32 = 17;

/// Number of fields in an extension node of the MPT.
/// An extension node contains a shared nibble path and a pointer to the next node,
/// totaling 2 fields.
pub global EXTENSION_NODE_NUM_FIELDS: u32 = 2;

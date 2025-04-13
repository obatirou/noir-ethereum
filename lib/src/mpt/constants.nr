/// Maximum length (in bytes) of a node in the Merkle Patricia Tree.
/// This value is derived from the maximum possible size of a branch node,
/// which is the largest node type in the MPT structure.
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

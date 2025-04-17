//! Storage Constants for Merkle Patricia Trie (MPT) Proof Verification
//!
//! This module defines the core constants used in Ethereum's storage Merkle Patricia Trie
//! proof verification. These constants define the maximum sizes and lengths for various
//! components of storage proofs, ensuring safe and efficient verification of storage
//! state in Ethereum.

/// Maximum depth of the storage trie proof.
/// This represents the maximum number of nodes that can be traversed
/// from the root to a leaf in the storage trie.
///
/// The value of 6 allows for:
/// - 1 root node
/// - Up to 5 internal nodes
/// - 1 leaf node
///
/// This depth is sufficient for Ethereum's storage trie structure while
/// maintaining reasonable circuit complexity circuits.
pub global MAX_STORAGE_DEPTH: u32 = 6;

/// Maximum length of a storage value in bytes.
/// Storage values in Ethereum are prefixed with a single byte indicating
/// the length, followed by up to 32 bytes of actual value data.
///
/// The value of 33 bytes allows for:
/// - 1 byte length prefix
/// - 32 bytes maximum value length (matching Ethereum's word size)
pub global MAX_STORAGE_VALUE_LENGTH: u32 = 33;

/// Maximum length of a leaf node in the storage trie.
/// A leaf node contains:
/// - The remaining nibbles of the key
/// - The RLP-encoded value
pub global MAX_STORAGE_LEAF_LENGTH: u32 = 69;

//! Types for Merkle Patricia Tree (MPT) implementation and proof verification.
//!
//! This module defines the core types used in the MPT implementation, which is a
//! modified version of the Patricia tree used in Ethereum for storing key-value pairs.

use super::constants::MAX_NODE_LEN;

/// A node in the Merkle Patricia Tree.
///
/// Represents a single node in the MPT structure, which can be one of:
/// - Branch node (17 children)
/// - Extension node (shared prefix + next node)
/// - Leaf node (key-value pair)
///
/// The size is fixed to MAX_NODE_LEN to ensure consistent hashing and storage.
pub type Node = [u8; MAX_NODE_LEN];

/// A leaf node in the Merkle Patricia Tree.
///
/// Represents a terminal node containing a key-value pair.
/// The length is parameterized to allow for different maximum leaf sizes
/// depending on the use case.
///
/// # Generics
/// - `MaxLeafLen`: Maximum length of the leaf node in bytes
pub type Leaf<let MaxLeafLen: u32> = [u8; MaxLeafLen];

/// A key in the Merkle Patricia Tree.
///
/// Represents the lookup key used to navigate the tree.
/// Keys are typically hashed addresses or other identifiers.
///
/// # Generics
/// - `MaxKeyLen`: Maximum length of the key in bytes
pub type Key<let MaxKeyLen: u32> = [u8; MaxKeyLen];

/// A value stored in the Merkle Patricia Tree.
///
/// Represents the data associated with a key in the tree.
/// Values can be account states, storage slots, or other application data.
///
/// # Generics
/// - `MaxValueLen`: Maximum length of the value in bytes
pub type Value<let MaxValueLen: u32> = [u8; MaxValueLen];

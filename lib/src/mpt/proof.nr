//! Structures for representing and verifying Merkle Patricia Trie (MPT) proofs in Ethereum.
//! This module provides the core data structures needed to represent and verify MPT proofs,
//! including the proof itself and its input parameters.
//!
//! The module defines two main structures:
//! - `Proof`: Represents a complete MPT proof with nodes and leaf data
//! - `ProofInput`: Bundles a key-value pair with its corresponding proof for verification

use super::types::{Key, Leaf, Node, Value};

/// Represents a complete Merkle Patricia Trie proof.
/// A proof consists of a sequence of nodes from the root to the leaf,
/// along with the leaf data and the depth of the proof.
///
/// # Generics
/// * `MaxDepth`: Maximum number of nodes allowed in the proof
/// * `MaxLeafLen`: Maximum length of the leaf data
///
/// # Fields
/// * `nodes`: Array of nodes forming the path from root to leaf
/// * `leaf`: The leaf node containing the value
/// * `depth`: The actual depth of the proof (number of nodes used)
pub struct Proof<let MaxDepth: u32, let MaxLeafLen: u32> {
    nodes: [Node; MaxDepth],
    leaf: Leaf<MaxLeafLen>,
    depth: u64,
}

impl<let MaxDepth: u32, let MaxLeafLen: u32> Proof<MaxDepth, MaxLeafLen> {
    /// Creates a new proof instance.
    ///
    /// # Arguments
    /// * `nodes`: Array of nodes forming the proof path
    /// * `leaf`: The leaf node containing the value
    /// * `depth`: The actual depth of the proof
    ///
    /// # Returns
    /// A new `Proof` instance
    pub fn new(nodes: [Node; MaxDepth], leaf: Leaf<MaxLeafLen>, depth: u64) -> Self {
        Self { nodes, leaf, depth }
    }

    /// Returns the array of nodes in the proof.
    pub fn nodes(self) -> [Node; MaxDepth] {
        self.nodes
    }

    /// Returns the leaf node containing the value.
    pub fn leaf(self) -> Leaf<MaxLeafLen> {
        self.leaf
    }

    /// Returns the depth of the proof (number of nodes used).
    pub fn depth(self) -> u64 {
        self.depth
    }
}

impl<let MaxDepth: u32, let MaxLeafLen: u32> Eq for Proof<MaxDepth, MaxLeafLen> {
    /// Implements equality comparison for proofs.
    /// Two proofs are considered equal if they have:
    /// - The same depth
    /// - The same leaf data
    /// - The same sequence of nodes
    fn eq(self, other: Self) -> bool {
        (self.depth == other.depth) & (self.leaf == other.leaf) & (self.nodes == other.nodes)
    }
}

/// Represents the input data for verifying a Merkle Patricia Trie proof.
/// This structure bundles together a key-value pair with its corresponding proof,
/// providing all the necessary data for verification.
///
/// # Generics
/// * `MaxKeyLen`: Maximum length of the key
/// * `MaxValueLen`: Maximum length of the value
/// * `MaxDepth`: Maximum number of nodes allowed in the proof
/// * `MaxLeafLen`: Maximum length of the leaf data
///
/// # Fields
/// * `key`: The key being looked up
/// * `value`: The expected value for the key
/// * `proof`: The proof to verify
pub struct ProofInput<let MaxKeyLen: u32, let MaxValueLen: u32, let MaxDepth: u32, let MaxLeafLen: u32> {
    key: Key<MaxKeyLen>,
    value: Value<MaxValueLen>,
    proof: Proof<MaxDepth, MaxLeafLen>,
}

impl<let MaxKeyLen: u32, let MaxValueLen: u32, let MaxDepth: u32, let MaxLeafLen: u32> ProofInput<MaxKeyLen, MaxValueLen, MaxDepth, MaxLeafLen> {
    /// Creates a new proof input instance.
    ///
    /// # Arguments
    /// * `key`: The key being looked up
    /// * `value`: The expected value for the key
    /// * `proof`: The proof to verify
    ///
    /// # Returns
    /// A new `ProofInput` instance
    pub fn new(
        key: Key<MaxKeyLen>,
        value: Value<MaxValueLen>,
        proof: Proof<MaxDepth, MaxLeafLen>,
    ) -> Self {
        Self { key, value, proof }
    }

    /// Returns the key being looked up.
    pub fn key(self) -> Key<MaxKeyLen> {
        self.key
    }

    /// Returns the expected value for the key.
    pub fn value(self) -> Value<MaxValueLen> {
        self.value
    }

    /// Returns the proof to verify.
    pub fn proof(self) -> Proof<MaxDepth, MaxLeafLen> {
        self.proof
    }
}

impl<let MaxKeyLen: u32, let MaxValueLen: u32, let MaxDepth: u32, let MaxLeafLen: u32> Eq for ProofInput<MaxKeyLen, MaxValueLen, MaxDepth, MaxLeafLen> {
    /// Implements equality comparison for proof inputs.
    /// Two proof inputs are considered equal if they have:
    /// - The same key
    /// - The same value
    /// - The same proof
    fn eq(self, other: Self) -> bool {
        (self.key == other.key) & (self.value == other.value) & (self.proof == other.proof)
    }
}

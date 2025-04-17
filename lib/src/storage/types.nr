//! Storage Proof Type Definition
//!
//! This module defines the StorageProof type used for verifying Ethereum storage state
//! in the Merkle Patricia Trie (MPT). The StorageProof type is a specialized version
//! of ProofInput that contains all necessary data to verify a storage slot's existence
//! and value in an account's storage trie.

use crate::mpt::proof::ProofInput;

use crate::account::constants::MAX_PREFIXED_KEY_NIBBLE_LENGTH;
use super::constants::{MAX_STORAGE_DEPTH, MAX_STORAGE_LEAF_LENGTH, MAX_STORAGE_VALUE_LENGTH};

/// A proof for verifying a storage slot's existence and value in an account's storage trie.
///
/// This type is a specialized version of ProofInput that contains all necessary data
/// to verify a storage slot in the Merkle Patricia Trie. It uses constants specific
/// to storage proofs to ensure proper sizing and verification.
///
/// # Type Parameters
///
/// The type uses the following constants for its generic parameters:
/// * `MAX_PREFIXED_KEY_NIBBLE_LENGTH` - Maximum length of the storage key in nibbles
/// * `MAX_STORAGE_VALUE_LENGTH` - Maximum length of the storage value in bytes
/// * `MAX_STORAGE_DEPTH` - Maximum depth of the storage trie proof
/// * `MAX_STORAGE_LEAF_LENGTH` - Maximum length of the leaf node in bytes
pub type StorageProof = ProofInput<MAX_PREFIXED_KEY_NIBBLE_LENGTH, MAX_STORAGE_VALUE_LENGTH, MAX_STORAGE_DEPTH, MAX_STORAGE_LEAF_LENGTH>;

//! Account Proof Type Definition
//!
//! This module defines the AccountProof type used for verifying Ethereum account state
//! in the Merkle Patricia Trie (MPT). The AccountProof type is a specialized version
//! of ProofInput that contains all necessary data to verify an account's existence
//! and state in the Ethereum state trie.
//!
//! The proof includes:
//! - The path from root to the account node
//! - The account's state data
//! - Verification metadata

use crate::mpt::proof::ProofInput;

use super::constants::{
    MAX_ACCOUNT_DEPTH, MAX_ACCOUNT_LEAF_LENGTH, MAX_ACCOUNT_STATE_LENGTH,
    MAX_PREFIXED_KEY_NIBBLE_LENGTH,
};

/// A proof for verifying an account's existence and state in the Ethereum state trie.
///
/// This type is a specialized version of ProofInput that contains all necessary data
/// to verify an account's state in the Merkle Patricia Trie.
pub type AccountProof = ProofInput<MAX_PREFIXED_KEY_NIBBLE_LENGTH, MAX_ACCOUNT_STATE_LENGTH, MAX_ACCOUNT_DEPTH, MAX_ACCOUNT_LEAF_LENGTH>;

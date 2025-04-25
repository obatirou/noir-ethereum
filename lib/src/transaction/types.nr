//! Ethereum Transaction Types and Proof Structures
//!
//! This module defines types used for representing Ethereum transactions and their
//! Merkle Patricia Trie (MPT) proofs. It includes:
//! - Transaction type definitions for different Ethereum transaction formats
//! - Transaction proof structures for MPT verification
//!
//! The module supports all major Ethereum transaction types:
//! - Legacy transactions (pre-EIP-2930)
//! - EIP-2930 transactions (Access Lists)
//! - EIP-1559 transactions (Fee Market)
//! - EIP-4844 transactions (Blob Transactions)
//! - EIP-7702 transactions (Future upgrade)

use crate::mpt::proof::ProofInput;
use super::constants::MAX_PREFIXED_KEY_NIBBLE_LENGTH;

/// The type of an Ethereum transaction.
///
/// This type represents the different transaction formats supported by Ethereum,
/// identified by their type prefix in the transaction payload.
///
/// # Values
///
/// * `0` - Legacy transaction (pre-EIP-2930)
/// * `1` - EIP-2930 transaction (Access Lists)
/// * `2` - EIP-1559 transaction (Fee Market)
/// * `3` - EIP-4844 transaction (Blob Transactions)
/// * `4` - EIP-7702 transaction (Future upgrade)
pub type TransactionType = u8;

/// A Merkle Patricia Trie proof for verifying transaction inclusion.
///
/// # Generics
///
/// * `MaxLeafLen` - Maximum length of a leaf node in the trie
/// * `MaxEncodedTxLen` - Maximum length of an encoded transaction
/// * `MaxDepthNoLeaf` - Maximum depth of the trie excluding leaf nodes
pub type TransactionProof<let MaxLeafLen: u32, let MaxEncodedTxLen: u32, let MaxDepthNoLeaf: u32> = ProofInput<MAX_PREFIXED_KEY_NIBBLE_LENGTH, MaxEncodedTxLen, MaxDepthNoLeaf, MaxLeafLen>;

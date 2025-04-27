//! Ethereum Receipt Types for Merkle Patricia Trie (MPT) Proofs
//!
//! This module defines types used for representing Ethereum transaction receipt proofs

use crate::mpt::proof::ProofInput;
use super::constants::{BLOOM_FILTER_LENGTH, MAX_PREFIXED_KEY_NIBBLE_LEN};

/// A bloom filter representing the log entries in a transaction receipt.
///
/// The bloom filter is a 256-byte array that efficiently encodes the presence
/// of log entries based on their address and topics. It allows for quick filtering
/// of logs without needing to decode the entire receipt.
///
/// # Size
///
/// The bloom filter is fixed at BLOOM_FILTER_LENGTH bytes (256 bytes = 2048 bits)
/// to ensure consistent hashing and storage in the Ethereum state.
pub type LogsBloom = [u8; BLOOM_FILTER_LENGTH];

/// A proof for verifying a transaction receipt in the receipts trie.
///
/// This type is a specialized version of ProofInput that contains all necessary data
/// to verify a receipt in the Merkle Patricia Trie.
///
/// # Generics
///
/// * `MaxEncodedLen` - Maximum length of the encoded receipt
/// * `MaxDepthNoLeaf` - Maximum depth of the trie excluding leaf nodes
/// * `MaxLeafLen` - Maximum length of the leaf data
pub type ReceiptProof<let MaxEncodedLen: u32, let MaxDepthNoLeaf: u32, let MaxLeafLen: u32> = ProofInput<MAX_PREFIXED_KEY_NIBBLE_LEN, MaxEncodedLen, MaxDepthNoLeaf, MaxLeafLen>;

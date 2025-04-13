//! Ethereum Hash Type Definition
//!
//! This module defines the Hash type used throughout Ethereum and related protocols.
//! A Hash is a 32-byte (256-bit) value that represents cryptographic hashes,
//! commonly used for:
//! - Block hashes
//! - Transaction hashes
//! - State root hashes
//! - Account hashes
//! - Keccak-256 hashes of arbitrary data

use super::bytes32::Bytes32;

/// The length of a Hash in bytes (32 bytes = 256 bits)
pub global HASH_LEN: u32 = 32;

/// A 32-byte hash value used in Ethereum.
///
/// This type alias represents a 256-bit cryptographic hash value,
/// which is the standard hash size used throughout Ethereum.
/// It is implemented as a Bytes32 to ensure proper type safety
/// and interoperability with other Ethereum components.
pub type Hash = Bytes32;

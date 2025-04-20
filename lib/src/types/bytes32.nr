//! Ethereum Bytes32 Type
//!
//! This module defines the Bytes32 type, which represents a 32-byte array commonly used in Ethereum
//! for storing hashes, addresses, and other fixed-size data.

/// The fixed length of a Bytes32 array in bytes
pub global BYTES32_LENGTH: u32 = 32;

/// A fixed-size array of 32 bytes, commonly used in Ethereum for hashes and addresses
///
/// This type is used to represent:
/// - Keccak-256 hashes (32 bytes)
/// - Fixed-size cryptographic data
pub type Bytes32 = [u8; BYTES32_LENGTH];

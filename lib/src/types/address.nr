//! Ethereum Address Type Definition
//!
//! This module defines the Address type used throughout Ethereum and related protocols.
//! An Ethereum address is a 20-byte (160-bit) identifier derived
//! from the last 20 bytes of the Keccak-256 hash of an ECDSA public key.

/// The length of Address in Bytes (20 bytes = 160 bits)
pub global ADDRESS_LENGTH: u32 = 20;

/// A 20-byte address value used in Ethereum.
///
/// This type alias represents a 160-bit address value,
/// which is the last 20 bytes of the Keccak-256 hash of an ECDSA public key.
pub type Address = [u8; ADDRESS_LENGTH];

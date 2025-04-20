//! Ethereum Block Header Type Definitions
//!
//! This module defines types used for representing Ethereum block headers in RLP format.
use super::constants::MAX_HEADER_SIZE;

/// A bounded vector type representing an RLP-encoded Ethereum block header.
pub type BlockHeaderRlp = BoundedVec<u8, MAX_HEADER_SIZE>;

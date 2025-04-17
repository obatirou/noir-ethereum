//! Storage Proof Verification Module
//!
//! This module provides functions for verifying storage slot proofs in Ethereum.
//! Storage proofs are Merkle proofs that demonstrate the existence and value of
//! specific storage slots in an Ethereum account's storage trie.
//!
//! The module supports:
//! - Verifying individual storage slot proofs
//! - Batch verification of multiple storage proofs

use crate::mpt::verify::verify_merkle_proof;
use crate::types::bytes32::Bytes32;
use super::types::StorageProof;

/// Verifies a single storage slot proof against a storage root.
///
/// This function checks that the provided storage proof correctly proves
/// the existence and value of a storage slot in the account's storage trie.
///
/// # Arguments
///
/// * `storage_proof` - The storage proof to verify
/// * `storage_root` - The root hash of the account's storage trie
///
/// # Panics
///
/// Panics if the proof is invalid or does not lead to the claimed storage root
pub fn verify_storage_proof(storage_proof: StorageProof, storage_root: Bytes32) {
    // Verify that the proof correctly links the key-value pair to the storage root
    verify_merkle_proof(
        storage_proof.key(),
        storage_proof.value(),
        storage_root,
        storage_proof.proof(),
    );
}

/// Verifies multiple storage slot proofs against a storage root.
///
/// This function performs batch verification of multiple storage proofs,
/// checking that each proof correctly proves its storage slot.
///
/// # Arguments
///
/// * `proofs` - Array of storage proofs to verify
/// * `storage_root` - The root hash of the account's storage trie
///
/// # Generics
///
/// * `N` - The number of proofs to verify
///
/// # Panics
///
/// Panics if any proof is invalid or does not lead to the claimed storage root
pub fn verify_storage_proofs<let N: u32>(proofs: [StorageProof; N], storage_root: Bytes32) {
    for i in 0..N {
        let proof_input = proofs[i];
        verify_storage_proof(proof_input, storage_root);
    }
}

mod verify_storage_proof_tests {
    use crate::fixtures::storage::contract_storage::{storage_proof, storage_root};
    use super::verify_storage_proof;

    #[test]
    fn test_verify_storage_proof() {
        verify_storage_proof(storage_proof, storage_root);
    }
}

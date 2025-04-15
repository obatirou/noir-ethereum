use crate::mpt::verify::verify_merkle_proof;
use crate::types::bytes32::Bytes32;
use super::types::StorageProof;

pub fn verify_storage_proof(storage_proof: StorageProof, storage_root: Bytes32) {
    verify_merkle_proof(
        storage_proof.key(),
        storage_proof.value(),
        storage_root,
        storage_proof.proof(),
    );
}

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

use crate::storage::{storage::verify_storage_proof, types::StorageProof};
use crate::types::hash::Hash;

#[export]
fn benchmark_verify_storage_proof(storage_proof: StorageProof, storage_root: Hash) {
    verify_storage_proof(storage_proof, storage_root);
}

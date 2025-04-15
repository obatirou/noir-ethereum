use ethereum::storage::types::StorageProof;
use ethereum::storage::verify_storage_proof;
use ethereum::types::hash::Hash;

fn main(storage_proof: StorageProof, storage_root: Hash) {
    verify_storage_proof(storage_proof, storage_root)
}

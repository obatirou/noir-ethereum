use crate::mpt::proof::ProofInput;
use super::account::Account;

use super::constants::{
    MAX_ACCOUNT_DEPTH, MAX_ACCOUNT_LEAF_LENGTH, MAX_ACCOUNT_STATE_LENGTH, MAX_KEY_LENGTH,
    MAX_STORAGE_DEPTH, MAX_STORAGE_LEAF_LENGTH, MAX_STORAGE_VALUE_LENGTH,
};

pub type AccountProof = ProofInput<MAX_KEY_LENGTH, MAX_ACCOUNT_STATE_LENGTH, MAX_ACCOUNT_DEPTH, MAX_ACCOUNT_LEAF_LENGTH>;
pub type StorageProof = ProofInput<MAX_KEY_LENGTH, MAX_STORAGE_VALUE_LENGTH, MAX_STORAGE_DEPTH, MAX_STORAGE_LEAF_LENGTH>;

pub struct StateAndStorageProofInput<let StorageProofsLen: u32> {
    account: Account,
    account_proof: AccountProof,
    storage_proof: [StorageProof; StorageProofsLen],
}

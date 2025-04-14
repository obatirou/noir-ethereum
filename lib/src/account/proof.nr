use crate::mpt::proof::ProofInput;
use super::account::Account;

pub struct StateAndStorageProofInput {
    account: Account,
    state_proof_input: ProofInput<MAX_PREFIXED_KEY_NIBBLE_LEN, MAX_ACCOUNT_STATE_LEN, MAX_ACCOUNT_DEPTH_NO_LEAF_M, MAX_ACCOUNT_LEAF_LEN>,
    storage_proof_input: ProofInput<MAX_PREFIXED_KEY_NIBBLE_LEN, MAX_STORAGE_VALUE_LEN, MAX_STORAGE_DEPTH_NO_LEAF_M, MAX_STORAGE_LEAF_LEN>,
}

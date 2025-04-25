use ethereum::transaction::{TransactionPartial, verify_transaction_proof};
use ethereum::transaction::types::{TransactionProof, TransactionType};
use ethereum::types::hash::Hash;

pub global MAX_LEAF_LENGTH: u32 = 256;
pub global MAX_DATA_LENGTH: u32 = 256;
pub global MAX_DEPTH_NO_LEAF: u32 = 4;
pub global MAX_ENCODED_TRANSACTION_LENGTH: u32 = 525;

fn main(
    transaction_index: u64,
    transaction_type: TransactionType,
    transaction: TransactionPartial<MAX_DATA_LENGTH>,
    transaction_proof: TransactionProof<MAX_LEAF_LENGTH, MAX_ENCODED_TRANSACTION_LENGTH, MAX_DEPTH_NO_LEAF>,
    transaction_root: Hash,
) {
    verify_transaction_proof(
        transaction_index,
        transaction_type,
        transaction,
        transaction_proof,
        transaction_root,
    )
}

use crate::{
    transaction::{
        transaction::{TransactionPartial, verify_transaction_proof},
        types::{TransactionProof, TransactionType},
    },
    types::hash::Hash,
};

#[export]
pub fn bench_verify_legacy_transaction(
    // Basic ETH Transfer Transaction with no data
    transaction_index: u64,
    transaction_type: TransactionType,
    transaction: TransactionPartial<2>,
    transaction_proof: TransactionProof<256, 128, 3>,
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

#[export]
pub fn bench_verify_eip1559_transaction(
    // Average EIP-1559 Transaction with minimal data
    transaction_index: u64,
    transaction_type: TransactionType,
    transaction: TransactionPartial<128>,
    transaction_proof: TransactionProof<256, 256, 4>,
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

use crate::{
    receipt::{receipt::{TransactionReceiptPartial, verify_receipt_proof}, types::ReceiptProof},
    transaction::types::TransactionType,
    types::hash::Hash,
};

#[export]
pub fn bench_verify_receipt_proof(
    block_number: u64,
    transaction_index: u64,
    transaction_type: TransactionType,
    receipt: TransactionReceiptPartial,
    receipt_proof: ReceiptProof<256, 4, 256>,
    receipt_root: Hash,
) {
    let _ = verify_receipt_proof(
        block_number,
        transaction_index,
        transaction_type,
        receipt,
        receipt_proof,
        receipt_root,
    );
}

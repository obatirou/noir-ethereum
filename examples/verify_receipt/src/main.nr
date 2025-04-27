use ethereum::receipt::{
    receipt::{TransactionReceiptPartial, verify_receipt_proof},
    types::ReceiptProof,
};

use ethereum::transaction::types::TransactionType;
use ethereum::types::hash::Hash;

pub global MAX_LEAF_LENGTH: u32 = 512;
pub global MAX_DEPTH_NO_LEAF: u32 = 4;
pub global MAX_ENCODED_RECEIPT_LENGTH: u32 = 512;

fn main(
    block_number: u64,
    transaction_index: u64,
    transaction_type: TransactionType,
    receipt: TransactionReceiptPartial,
    receipt_proof: ReceiptProof<MAX_ENCODED_RECEIPT_LENGTH, MAX_DEPTH_NO_LEAF, MAX_LEAF_LENGTH>,
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

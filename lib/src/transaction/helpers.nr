use crate::rlp::{decode::{decode_list, decode_string}, list::RlpList};
use crate::types::fragment::Fragment;

use crate::helpers::bytes::{right_pad, u64_to_u8};
use super::constants::{MAX_TRANSACTION_FIELDS_COUNT, TRANSACTION_TYPE_FIELD_LAYOUT};
use super::transaction::TransactionPartial;
use super::types::TransactionType;

pub fn assert_tx_rlp_equals<let MaxDataLen: u32, let MaxEncodedDataLen: u32>(
    tx_rlp: Fragment<u8, MaxEncodedDataLen>,
    tx_type: TransactionType,
    tx: TransactionPartial<MaxDataLen>,
) {
    let rlp_list: RlpList<MAX_TRANSACTION_FIELDS_COUNT> = decode_list(tx_rlp);

    let field_layout = TRANSACTION_TYPE_FIELD_LAYOUT[tx_type];
    assert(
        rlp_list.len() == field_layout.field_count(),
        "Invalid number of fields in transaction RLP",
    );

    rlp_list.get(field_layout.nonce_index()).assert_eq_u64("Nonce", tx_rlp, tx.nonce());

    rlp_list.get(field_layout.gas_limit_index()).assert_eq_u64("Gas limit", tx_rlp, tx.gas_limit());

    if (tx.to().is_some()) {
        rlp_list.get(field_layout.to_index()).assert_eq_address(
            "To",
            tx_rlp,
            tx.to().expect(f"to is missing"),
        );
    } else {
        rlp_list.get(field_layout.to_index()).assert_empty_string("To");
    }

    rlp_list.get(field_layout.value_index()).assert_eq_u128("Value", tx_rlp, tx.value());

    rlp_list.get(field_layout.data_index()).assert_eq_bounded_vec("Data", tx_rlp, tx.data());

    rlp_list.get(field_layout.signature_index()).assert_eq_u8("V", tx_rlp, tx.v());
    rlp_list.get(field_layout.signature_index() + 1).assert_eq_bytes32("R", tx_rlp, tx.r());
    rlp_list.get(field_layout.signature_index() + 2).assert_eq_bytes32("S", tx_rlp, tx.s());
}

pub fn split_into_tx_type_and_rlp<let MaxEncodedLen: u32>(
    is_legacy: bool,
    encoded: Fragment<u8, MaxEncodedLen>,
) -> (u8, Fragment<u8, MaxEncodedLen>) {
    // RLP of Legacy Transaction contains no prefix byte, but is padded with a single zero byte.
    let mut rlp = encoded;
    if is_legacy {
        assert_eq(rlp.pop_back(), 0, "RLP receipt exceeds MAX_RLP_LENGTH");
        (0, rlp)
    } else {
        // RLP of Non-Legacy Transaction contains a prefix byte indicating the type of transaction.
        let tx_type = rlp.pop_front();
        (tx_type, rlp)
    }
}

pub fn assert_transaction_index_equals<let MaxKeyLen: u32>(
    key_as_rlp: Fragment<u8, MaxKeyLen>,
    index: u64,
) {
    let key_fragment = decode_string(key_as_rlp);
    let length = key_fragment.len();
    let offset = key_fragment.offset();
    assert(length + offset == key_as_rlp.len(), "Key is not an RLP encoded string");

    if (length == 0) {
        assert(index == 0, "Key does not match RLP encoded transaction index");
    } else {
        let tx_idx_bytes = Fragment::from_vec(right_pad(u64_to_u8(index)));
        assert(
            key_as_rlp.sub_fragment(offset, length).eq(tx_idx_bytes),
            "Key does not match RLP -encoded transaction index",
        );
    }
}

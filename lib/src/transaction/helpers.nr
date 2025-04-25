//! Ethereum Transaction Helper Functions
//!
//! This module provides helper functions for working with Ethereum transactions in RLP format.

use crate::rlp::{decode::{decode_list, decode_string}, list::RlpList};
use crate::types::fragment::Fragment;

use crate::helpers::bytes::{right_pad, u64_to_u8};
use super::constants::{MAX_TRANSACTION_FIELDS_COUNT, TRANSACTION_TYPE_FIELD_LAYOUT};
use super::transaction::TransactionPartial;
use super::types::TransactionType;

/// Verifies that a transaction's RLP encoding matches the expected values.
///
/// This function performs a comprehensive check of all transaction fields in RLP format,
/// ensuring that the encoded data matches the provided transaction data. It verifies:
/// - The number of fields matches the expected layout for the transaction type
/// - Nonce value matches
/// - Gas limit matches
/// - To address matches (or is empty for contract creation)
/// - Value matches
/// - Data matches
/// - Signature components (v, r, s) match
///
/// # Arguments
///
/// * `tx_rlp` - The RLP-encoded transaction data
/// * `tx_type` - The type of transaction (Legacy, EIP-2930, EIP-1559, etc.)
/// * `tx` - The expected transaction data
///
/// # Generics
///
/// * `MaxDataLen` - Maximum length of transaction data
/// * `MaxEncodedDataLen` - Maximum length of encoded transaction data
///
/// # Panics
///
/// Panics with descriptive messages if any field does not match the expected value
pub fn assert_tx_rlp_equals<let MaxDataLen: u32, let MaxEncodedDataLen: u32>(
    tx_rlp: Fragment<u8, MaxEncodedDataLen>,
    tx_type: TransactionType,
    tx: TransactionPartial<MaxDataLen>,
) {
    // Decode the RLP data into a list of fields
    let rlp_list: RlpList<MAX_TRANSACTION_FIELDS_COUNT> = decode_list(tx_rlp);

    // Get the field layout for this transaction type and verify field count
    let field_layout = TRANSACTION_TYPE_FIELD_LAYOUT[tx_type];
    assert(
        rlp_list.len() == field_layout.field_count(),
        "Invalid number of fields in transaction RLP",
    );

    // Verify each transaction field matches the expected value
    rlp_list.get(field_layout.nonce_index()).assert_eq_u64("Nonce", tx_rlp, tx.nonce());

    rlp_list.get(field_layout.gas_limit_index()).assert_eq_u64("Gas limit", tx_rlp, tx.gas_limit());

    // Handle the 'to' address field - it can be empty for contract creation
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

    // Verify signature components
    rlp_list.get(field_layout.signature_index()).assert_eq_u8("V", tx_rlp, tx.v());
    rlp_list.get(field_layout.signature_index() + 1).assert_eq_bytes32("R", tx_rlp, tx.r());
    rlp_list.get(field_layout.signature_index() + 2).assert_eq_bytes32("S", tx_rlp, tx.s());
}

/// Splits encoded transaction data into its type and RLP components.
///
/// This function handles both legacy and non-legacy transaction formats:
/// - Legacy transactions have no type prefix but are padded with a zero byte
/// - Non-legacy transactions (EIP-2930, EIP-1559, etc.) have a type prefix byte
///
/// # Arguments
///
/// * `is_legacy` - Whether the transaction is a legacy format
/// * `encoded` - The encoded transaction data
///
/// # Generics
///
/// * `MaxEncodedLen` - Maximum length of encoded transaction data
///
/// # Returns
///
/// A tuple containing:
/// - The transaction type (0 for legacy, 1-4 for non-legacy)
/// - The RLP-encoded transaction data without the type prefix
///
/// # Panics
///
/// Panics if the legacy transaction padding is invalid
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

/// Verifies that a transaction index in RLP format matches the expected value.
///
/// This function validates that a key in RLP format correctly represents
/// a transaction index. It handles both empty keys (index 0) and
/// non-empty keys containing the RLP-encoded index.
///
/// # Arguments
///
/// * `key_as_rlp` - The key in RLP format to verify
/// * `index` - The expected transaction index
///
/// # Generics
///
/// * `MaxKeyLen` - Maximum length of the key
///
/// # Panics
///
/// Panics if:
/// - The key is not a valid RLP-encoded string
/// - The key does not match the expected index
pub fn assert_transaction_index_equals<let MaxKeyLen: u32>(
    key_as_rlp: Fragment<u8, MaxKeyLen>,
    index: u64,
) {
    // Decode the key as an RLP string and verify its format
    let key_fragment = decode_string(key_as_rlp);
    let length = key_fragment.len();
    let offset = key_fragment.offset();
    assert(length + offset == key_as_rlp.len(), "Key is not an RLP encoded string");

    // Handle both empty keys (index 0) and non-empty keys
    if (length == 0) {
        assert(index == 0, "Key does not match RLP encoded transaction index");
    } else {
        // For non-empty keys, verify the encoded index matches
        let tx_idx_bytes = Fragment::from_vec(right_pad(u64_to_u8(index)));
        assert(
            key_as_rlp.sub_fragment(offset, length).eq(tx_idx_bytes),
            "Key does not match RLP -encoded transaction index",
        );
    }
}

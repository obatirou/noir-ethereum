//! Ethereum Transaction Constants
//!
//! This module defines constants used for working with Ethereum transactions.
//! It includes:
//! - Maximum field counts and sizes for transactions
//! - Transaction type field layouts for different transaction types
//! - Maximum lengths for encoded transactions and RLP data
//! - Maximum depths and key lengths for transaction verification

use super::transaction::TransactionPartialFieldLayout;

/// Maximum number of fields allowed in a transaction
///
/// This constant defines the upper limit on the number of fields that can be
/// present in any Ethereum transaction type (Legacy, EIP-2930, EIP-1559, EIP-4844).
/// It is used to ensure that transaction verification circuits can handle all
/// possible transaction formats.
pub global MAX_TRANSACTION_FIELDS_COUNT: u32 = 14;

/// Field layouts for different transaction types
///
/// This array defines the field layouts for each transaction type, specifying:
/// - Total number of fields
/// - Field indices for each component
/// - Field types and their positions
///
/// The layouts are used to verify that transactions are properly structured
/// according to their type-specific format.
pub global TRANSACTION_TYPE_FIELD_LAYOUT: [TransactionPartialFieldLayout; 5] = [
    TransactionPartialFieldLayout::new(9, 0, 2, 3, 4, 5, 6), // Legacy transaction
    TransactionPartialFieldLayout::new(11, 1, 3, 4, 5, 6, 8), // EIP-2930 transaction
    TransactionPartialFieldLayout::new(12, 1, 4, 5, 6, 7, 9), // EIP-1559 transaction
    TransactionPartialFieldLayout::new(14, 1, 4, 5, 6, 7, 11), // EIP-4844 transaction
    TransactionPartialFieldLayout::new(13, 1, 4, 5, 6, 7, 10), // Reserved for future use
];

/// Maximum length of a transaction index in bytes
pub global MAX_KEY_LENGTH: u32 = 3;

/// Maximum depth of non-leaf nodes in transaction verification
///
/// This constant represents the maximum depth of the Merkle tree used for
/// transaction verification, excluding leaf nodes. The depth can vary based on
/// the number of transactions in a block.
pub global MAX_DEPTH_NO_LEAF: u32 = 6;

/// Maximum length of a prefixed key in nibbles
///
/// This constant represents the maximum length of a key when represented in nibbles
/// (half-bytes) with its prefix. It is calculated as (MAX_KEY_LENGTH + 1) * 2
/// to account for the prefix byte and conversion to nibbles.
pub global MAX_PREFIXED_KEY_NIBBLE_LENGTH: u32 = 8;

//! Ethereum Transaction Receipt Helper Functions
//!
//! This module provides helper functions for working with Ethereum transaction receipts.

use crate::rlp::{decode::decode_list, list::RlpList};
use crate::transaction::{helpers::split_into_tx_type_and_rlp, types::TransactionType};
use crate::types::fragment::Fragment;

use crate::helpers::bounded_vec::bounded_vec_map;
use crate::types::address::Address;
use crate::types::bytes32::Bytes32;
use super::constants::{
    BLOOM_FILTER_LENGTH, BYZANTIUM_BLOCK_NUMBER, CUMULATIVE_GAS_USED_INDEX, LOG_ADDRESS_INDEX,
    LOG_DATA_INDEX, LOG_FIELDS_COUNT, LOG_TOPICS_INDEX, LOGS_BLOOM_INDEX, LOGS_INDEX,
    RECEIPT_FIELDS_COUNT, STATE_ROOT_INDEX, STATUS_INDEX,
};
use super::receipt::Log;
use super::receipt::TransactionReceiptPartial;

/// Checks if a block number is before the Byzantium hard fork.
///
/// The Byzantium hard fork introduced the status field in transaction receipts.
/// Pre-Byzantium receipts used the state root field instead.
///
/// # Arguments
///
/// * `block_number` - The block number to check
///
/// # Returns
///
/// `true` if the block is before Byzantium, `false` otherwise
pub fn is_pre_byzantium(block_number: u64) -> bool {
    block_number < BYZANTIUM_BLOCK_NUMBER as u64
}

/// Verifies that an RLP-encoded receipt matches a partial receipt.
///
/// This function:
/// 1. Decodes the RLP-encoded receipt
/// 2. Verifies the number of fields
/// 3. Checks each field matches the expected value
/// 4. Handles pre and post Byzantium receipts differently
///
/// # Arguments
///
/// * `is_pre_byzantium` - Whether the receipt is from before the Byzantium hard fork
/// * `receipt_rlp` - The RLP-encoded receipt
/// * `receipt` - The partial receipt to compare against
///
/// # Returns
///
/// The decoded RLP list if verification succeeds
///
/// # Panics
///
/// Panics if:
/// - The number of fields doesn't match
/// - Required fields are missing
/// - Field values don't match
pub fn assert_receipt_rlp_equals<let MaxEncodedLen: u32>(
    is_pre_byzantium: bool,
    receipt_rlp: Fragment<u8, MaxEncodedLen>,
    receipt: TransactionReceiptPartial,
) -> RlpList<RECEIPT_FIELDS_COUNT> {
    // Decode the RLP-encoded receipt
    let receipt_rlp_list: RlpList<RECEIPT_FIELDS_COUNT> = decode_list(receipt_rlp);
    assert(
        receipt_rlp_list.len() == RECEIPT_FIELDS_COUNT,
        "Invalid number of fields in receipt RLP",
    );

    // Check state root for pre-Byzantium receipts, status for post-Byzantium
    if (is_pre_byzantium) {
        receipt_rlp_list.get(STATE_ROOT_INDEX).assert_eq_bytes32(
            "State root",
            receipt_rlp,
            receipt.state_root().expect(f"State root is missing"),
        );
    } else {
        receipt_rlp_list.get(STATUS_INDEX).assert_eq_u8(
            "Status",
            receipt_rlp,
            receipt.status().expect(f"Status is missing"),
        );
    }

    // Verify cumulative gas used
    receipt_rlp_list.get(CUMULATIVE_GAS_USED_INDEX).assert_eq_u64(
        "Cumulative gas used",
        receipt_rlp,
        receipt.cumulative_gas_used(),
    );

    // Verify logs bloom
    receipt_rlp_list.get(LOGS_BLOOM_INDEX).assert_eq_bytes(
        "Logs bloom",
        receipt_rlp,
        Fragment::new_with_length(BLOOM_FILTER_LENGTH as u64, receipt.logs_bloom()),
    );

    receipt_rlp_list
}

/// Verifies that an encoded receipt matches a partial receipt.
///
/// This function:
/// 1. Splits the encoded receipt into type and RLP parts
/// 2. Verifies the transaction type
/// 3. Checks if the receipt is pre or post Byzantium
/// 4. Verifies the RLP encoding matches the partial receipt
///
/// # Arguments
///
/// * `block_number` - The block number for Byzantium check
/// * `tx_type` - The expected transaction type
/// * `encoded_receipt` - The encoded receipt to verify
/// * `receipt` - The partial receipt to compare against
///
/// # Returns
///
/// The decoded RLP list if verification succeeds
///
/// # Panics
///
/// Panics if:
/// - The transaction type doesn't match
/// - The RLP encoding doesn't match the partial receipt
pub fn assert_receipt_equals<let MaxEncodedLen: u32>(
    block_number: u64,
    tx_type: TransactionType,
    encoded_receipt: Fragment<u8, MaxEncodedLen>,
    receipt: TransactionReceiptPartial,
) -> RlpList<RECEIPT_FIELDS_COUNT> {
    let is_legacy = tx_type == 0;
    let (tx_type, receipt_rlp) = split_into_tx_type_and_rlp(is_legacy, encoded_receipt);
    let is_pre_byzantium = is_pre_byzantium(block_number);

    assert(tx_type == tx_type, "Invalid transaction type");
    assert_receipt_rlp_equals(is_pre_byzantium, receipt_rlp, receipt)
}

/// Extracts a log entry from an RLP-encoded receipt.
///
/// This function:
/// 1. Extracts the logs fragment from the receipt
/// 2. Gets the specific log entry by index
/// 3. Decodes the log entry into address, topics, and data
/// 4. Creates a Log struct with the extracted data
///
/// # Arguments
///
/// * `receipt_rlp_fragment` - The RLP-encoded receipt
/// * `receipt_rlp_list` - The decoded receipt RLP list
/// * `log_index` - The index of the log to extract
///
/// # Returns
///
/// A Log struct containing the extracted log entry
///
/// # Panics
///
/// Panics if:
/// - The log index is invalid
/// - The log entry has invalid fields
pub fn extract_log<let MaxReceiptRlpLen: u32, let MaxLogsCount: u32, let MaxLogDataLen: u32, let MaxTopicsCount: u32>(
    receipt_rlp_fragment: Fragment<u8, MaxReceiptRlpLen>,
    receipt_rlp_list: RlpList<RECEIPT_FIELDS_COUNT>,
    log_index: u32,
) -> Log<MaxLogDataLen, MaxTopicsCount> {
    // Extract the logs fragment and specific log entry
    let logs_fragment = extract_logs_fragment(receipt_rlp_fragment, receipt_rlp_list);
    let log_fragment = extract_log_fragment(logs_fragment, log_index);

    // Decode the log entry
    let log_values_rlp_list: RlpList<LOG_FIELDS_COUNT> = decode_list(log_fragment);
    assert(log_values_rlp_list.len() == LOG_FIELDS_COUNT, "Invalid Log fields count");

    // Extract address, topics, and data
    let address: Address = extract_address(log_fragment, log_values_rlp_list).to_array();
    let topics: BoundedVec<Bytes32, MaxTopicsCount> = bounded_vec_map(
        extract_topics(log_fragment, log_values_rlp_list),
        Fragment::to_array,
    );
    let data: BoundedVec<u8, MaxLogDataLen> =
        extract_data(log_fragment, log_values_rlp_list).to_bounded_vec();

    Log::new(address, topics, data)
}

/// Extracts the logs fragment from an RLP-encoded receipt.
///
/// This function:
/// 1. Gets the logs field from the receipt RLP list
/// 2. Creates a fragment containing just the logs data
///
/// # Arguments
///
/// * `receipt_rlp_fragment` - The RLP-encoded receipt
/// * `receipt_rlp_list` - The decoded receipt RLP list
///
/// # Returns
///
/// A fragment containing the logs data
pub fn extract_logs_fragment<let MaxReceiptRlpFragmentLen: u32, let MaxLogsCount: u32>(
    receipt_rlp_fragment: Fragment<u8, MaxReceiptRlpFragmentLen>,
    receipt_rlp_list: RlpList<RECEIPT_FIELDS_COUNT>,
) -> Fragment<u8, MaxReceiptRlpFragmentLen> {
    let logs_rlp_fragment = receipt_rlp_list.get(LOGS_INDEX);
    receipt_rlp_fragment.sub_fragment(logs_rlp_fragment.offset(), logs_rlp_fragment.len())
}

/// Extracts a specific log entry fragment from the logs fragment.
///
/// This function:
/// 1. Decodes the logs list
/// 2. Gets the specific log entry by index
/// 3. Creates a fragment containing just that log entry
///
/// # Arguments
///
/// * `logs_rlp_fragment` - The RLP-encoded logs
/// * `log_index` - The index of the log to extract
///
/// # Returns
///
/// A fragment containing the specific log entry
pub fn extract_log_fragment<let MaxLogsRlpFragmentLen: u32, let MaxLogsCount: u32>(
    logs_rlp_fragment: Fragment<u8, MaxLogsRlpFragmentLen>,
    log_index: u32,
) -> Fragment<u8, MaxLogsRlpFragmentLen> {
    let logs_rlp_list: RlpList<MaxLogsCount> = decode_list(logs_rlp_fragment);
    let log_fragment = logs_rlp_list.get(log_index);
    logs_rlp_fragment.sub_fragment(log_fragment.offset(), log_fragment.len())
}

/// Extracts the address field from a log entry.
///
/// This function:
/// 1. Gets the address field from the log RLP list
/// 2. Creates a fragment containing just the address data
///
/// # Arguments
///
/// * `log_fragment` - The RLP-encoded log entry
/// * `log_values_rlp_list` - The decoded log RLP list
///
/// # Returns
///
/// A fragment containing the address data
pub fn extract_address<let MaxLogsRlpFragmentLen: u32>(
    log_fragment: Fragment<u8, MaxLogsRlpFragmentLen>,
    log_values_rlp_list: RlpList<LOG_FIELDS_COUNT>,
) -> Fragment<u8, MaxLogsRlpFragmentLen> {
    let address_fragment = log_values_rlp_list.get(LOG_ADDRESS_INDEX);
    log_fragment.sub_fragment(address_fragment.offset(), address_fragment.len())
}

/// Extracts the topics array from a log entry.
///
/// This function:
/// 1. Gets the topics field from the log RLP list
/// 2. Decodes the topics list
/// 3. Creates fragments for each topic
///
/// # Arguments
///
/// * `log_fragment` - The RLP-encoded log entry
/// * `log_values_rlp_list` - The decoded log RLP list
///
/// # Returns
///
/// A bounded vector of fragments containing the topics
pub fn extract_topics<let MaxLogsRlpFragmentLen: u32, let MaxTopicsCount: u32>(
    log_fragment: Fragment<u8, MaxLogsRlpFragmentLen>,
    log_values_rlp_list: RlpList<LOG_FIELDS_COUNT>,
) -> BoundedVec<Fragment<u8, MaxLogsRlpFragmentLen>, MaxTopicsCount> {
    let log_topics_fragment = log_values_rlp_list.get(LOG_TOPICS_INDEX);
    let topics_fragment =
        log_fragment.sub_fragment(log_topics_fragment.offset(), log_topics_fragment.len());
    let topics_rlp_list: RlpList<MaxTopicsCount> = decode_list(topics_fragment);

    bounded_vec_map(
        topics_rlp_list,
        |topic_rlp_fragment| {
            topics_fragment.sub_fragment(topic_rlp_fragment.offset(), topic_rlp_fragment.len())
        },
    )
}

/// Extracts the data field from a log entry.
///
/// This function:
/// 1. Gets the data field from the log RLP list
/// 2. Creates a fragment containing just the data
///
/// # Arguments
///
/// * `log_fragment` - The RLP-encoded log entry
/// * `log_values_rlp_list` - The decoded log RLP list
///
/// # Returns
///
/// A fragment containing the log data
pub fn extract_data<let MaxLogsRlpFragmentLen: u32>(
    log_fragment: Fragment<u8, MaxLogsRlpFragmentLen>,
    log_values_rlp_list: RlpList<LOG_FIELDS_COUNT>,
) -> Fragment<u8, MaxLogsRlpFragmentLen> {
    let data_fragment = log_values_rlp_list.get(LOG_DATA_INDEX);
    log_fragment.sub_fragment(data_fragment.offset(), data_fragment.len())
}

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

pub fn is_pre_byzantium(block_number: u64) -> bool {
    block_number < BYZANTIUM_BLOCK_NUMBER as u64
}

pub fn assert_receipt_rlp_equals<let MaxEncodedLen: u32, let MaxLogsLen: u32, let MaxLogDataLen: u32, let MaxTopicsCount: u32>(
    is_pre_byzantium: bool,
    receipt_rlp: Fragment<u8, MaxEncodedLen>,
    receipt: TransactionReceiptPartial<MaxLogsLen, MaxLogDataLen, MaxTopicsCount>,
) -> RlpList<RECEIPT_FIELDS_COUNT> {
    let receipt_rlp_list: RlpList<RECEIPT_FIELDS_COUNT> = decode_list(receipt_rlp);
    assert(
        receipt_rlp_list.len() == RECEIPT_FIELDS_COUNT,
        "Invalid number of fields in receipt RLP",
    );

    if (is_pre_byzantium) {
        receipt_rlp_list.get(STATE_ROOT_INDEX).assert_eq_bytes32(
            "State root",
            receipt_rlp,
            receipt.state_root().expect(f"State root is missing"),
        );
    } else {
        receipt_rlp_list.get(STATUS_INDEX).assert_eq_u1(
            "Status",
            receipt_rlp,
            receipt.status().expect(f"Status is missing"),
        );
    }

    receipt_rlp_list.get(CUMULATIVE_GAS_USED_INDEX).assert_eq_u64(
        "Cumulative gas used",
        receipt_rlp,
        receipt.cumulative_gas_used(),
    );

    receipt_rlp_list.get(LOGS_BLOOM_INDEX).assert_eq_bytes(
        "Logs bloom",
        receipt_rlp,
        Fragment::new_with_length(BLOOM_FILTER_LENGTH as u64, receipt.logs_bloom()),
    );

    receipt_rlp_list
}

pub fn assert_receipt_equals<let MaxEncodedLen: u32, let MaxLogsLen: u32, let MaxLogDataLen: u32, let MaxTopicsCount: u32>(
    block_number: u64,
    tx_type: TransactionType,
    encoded_receipt: Fragment<u8, MaxEncodedLen>,
    receipt: TransactionReceiptPartial<MaxLogsLen, MaxLogDataLen, MaxTopicsCount>,
) -> RlpList<RECEIPT_FIELDS_COUNT> {
    let is_legacy = tx_type == 0;
    let (tx_type, receipt_rlp) = split_into_tx_type_and_rlp(is_legacy, encoded_receipt);
    let is_pre_byzantium = is_pre_byzantium(block_number);

    assert(tx_type == tx_type, "Invalid transaction type");
    assert_receipt_rlp_equals(is_pre_byzantium, receipt_rlp, receipt)
}

pub fn extract_log<let MaxReceiptRlpLen: u32, let MaxLogsCount: u32, let MaxLogDataLen: u32, let MaxTopicsCount: u32>(
    receipt_rlp_fragment: Fragment<u8, MaxReceiptRlpLen>,
    receipt_rlp_list: RlpList<RECEIPT_FIELDS_COUNT>,
    log_index: u32,
) -> Log<MaxLogDataLen, MaxTopicsCount> {
    let logs_fragment = extract_logs_fragment(receipt_rlp_fragment, receipt_rlp_list);
    let log_fragment = extract_log_fragment(logs_fragment, log_index);

    let log_values_rlp_list: RlpList<LOG_FIELDS_COUNT> = decode_list(log_fragment);
    assert(log_values_rlp_list.len() == LOG_FIELDS_COUNT, "Invalid Log fields count");

    let address: Address = extract_address(log_fragment, log_values_rlp_list).to_array();
    let topics: BoundedVec<Bytes32, MaxTopicsCount> = bounded_vec_map(
        extract_topics(log_fragment, log_values_rlp_list),
        Fragment::to_array,
    );
    let data: BoundedVec<u8, MaxLogDataLen> =
        extract_data(log_fragment, log_values_rlp_list).to_bounded_vec();

    Log::new(address, topics, data)
}

pub fn extract_logs_fragment<let MaxReceiptRlpFragmentLen: u32, let MaxLogsCount: u32>(
    receipt_rlp_fragment: Fragment<u8, MaxReceiptRlpFragmentLen>,
    receipt_rlp_list: RlpList<RECEIPT_FIELDS_COUNT>,
) -> Fragment<u8, MaxReceiptRlpFragmentLen> {
    let logs_rlp_fragment = receipt_rlp_list.get(LOGS_INDEX);
    receipt_rlp_fragment.sub_fragment(logs_rlp_fragment.offset(), logs_rlp_fragment.len())
}

pub fn extract_log_fragment<let MaxLogsRlpFragmentLen: u32, let MaxLogsCount: u32>(
    logs_rlp_fragment: Fragment<u8, MaxLogsRlpFragmentLen>,
    log_index: u32,
) -> Fragment<u8, MaxLogsRlpFragmentLen> {
    let logs_rlp_list: RlpList<MaxLogsCount> = decode_list(logs_rlp_fragment);
    let log_fragment = logs_rlp_list.get(log_index);
    logs_rlp_fragment.sub_fragment(log_fragment.offset(), log_fragment.len())
}

pub fn extract_address<let MaxLogsRlpFragmentLen: u32>(
    log_fragment: Fragment<u8, MaxLogsRlpFragmentLen>,
    log_values_rlp_list: RlpList<LOG_FIELDS_COUNT>,
) -> Fragment<u8, MaxLogsRlpFragmentLen> {
    let address_fragment = log_values_rlp_list.get(LOG_ADDRESS_INDEX);
    log_fragment.sub_fragment(address_fragment.offset(), address_fragment.len())
}

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

pub fn extract_data<let MaxLogsRlpFragmentLen: u32>(
    log_fragment: Fragment<u8, MaxLogsRlpFragmentLen>,
    log_values_rlp_list: RlpList<LOG_FIELDS_COUNT>,
) -> Fragment<u8, MaxLogsRlpFragmentLen> {
    let data_fragment = log_values_rlp_list.get(LOG_DATA_INDEX);
    log_fragment.sub_fragment(data_fragment.offset(), data_fragment.len())
}

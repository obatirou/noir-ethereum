use std::hash::keccak256;

use crate::account::constants::MAX_PREFIXED_KEY_NIBBLE_LENGTH;
use crate::helpers::bytes::right_pad;
use crate::rlp::decode::decode_string;
use crate::types::{bytes32::{Bytes32, BYTES32_LENGTH}, fragment::Fragment, hash::HASH_LENGTH};

use super::constants::MAX_STORAGE_VALUE_LENGTH;

pub fn assert_storage_key_equals(
    expected_key: Bytes32,
    prefixed_key: [u8; MAX_PREFIXED_KEY_NIBBLE_LENGTH],
) {
    let storage_key_hash_fragment = Fragment::new(
        (MAX_PREFIXED_KEY_NIBBLE_LENGTH - HASH_LENGTH) as u64,
        HASH_LENGTH as u64,
        prefixed_key,
    );

    let other_storage_key_hash_fragment =
        Fragment::from_array(keccak256(expected_key, BYTES32_LENGTH as u32));

    assert(
        storage_key_hash_fragment.eq(other_storage_key_hash_fragment),
        "Storage key does not match the argument",
    );
}

fn get_fragment<let N: u32>(left_padded_value: [u8; N]) -> Fragment<u8, N> {
    let value_length = right_pad(left_padded_value).len();
    let value_offset = N - value_length;
    Fragment::new(value_offset as u64, value_length as u64, left_padded_value)
}

pub fn get_storage_value(
    rlp_encoded_value: [u8; MAX_STORAGE_VALUE_LENGTH],
) -> [u8; MAX_STORAGE_VALUE_LENGTH] {
    let mut storage_value = get_fragment(rlp_encoded_value);
    let rlp_fragment = decode_string(storage_value);
    let rlp_header_length = rlp_fragment.offset();

    // Storage value is maximum 32 bytes long, so its RLP-encoding's header is maximum 1 byte long.
    assert(rlp_header_length <= 1, "Expected RLP header to be maximum 1 byte long");

    if rlp_fragment.offset() == 1 {
        let rlp_header_position = storage_value.offset();
        storage_value.set(rlp_header_position - storage_value.offset(), 0);
    }

    storage_value.data()
}

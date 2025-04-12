//! RLP (Recursive Length Prefix) Decoding Module
//!
//! This module provides functions for decoding RLP-encoded data into structured
//! representations. RLP is the main encoding method used to serialize objects
//! in Ethereum, and this module handles the conversion from raw bytes to
//! meaningful data structures.
//!
//! The module supports decoding:
//! - Single bytes
//! - Short strings (0-55 bytes)
//! - Long strings (>55 bytes)
//! - Lists of items
//!
//! # RLP Encoding Rules
//!
//! RLP encoding follows these rules:
//! - Single byte: If value < 0x80, encoded as is
//! - Short string: If length 0-55, [0x80 + length, value]
//! - Long string: If length > 55, [0xb7 + length_of_length, length, value]
//! - List: [0xc0 + length, items]

use super::{constants::{List, String}, helpers::get_list_len};
use std::wrapping_sub;

use crate::helpers::if_else;
use crate::rlp::{fragment::RlpFragment, header::RlpHeader, list::RlpList};
use crate::types::fragment::Fragment;

/// Decodes the first byte of RLP-encoded data into an RLP header.
///
/// This function analyzes the first byte of RLP-encoded data to determine:
/// - The type of data (single byte, string, or list)
/// - The offset to the actual data
/// - The length of the data
///
/// # Arguments
///
/// * `data` - A fragment containing the RLP-encoded data
///
/// # Returns
///
/// An `RlpHeader` containing metadata about the decoded data
///
/// # RLP Byte Ranges
///
/// - Single byte: < 0x80
/// - Short string: < 0xb8
/// - Long string: < 0xc0
/// - List: < 0xf8
pub fn decode_to_rlp_header<let N: u32>(data: Fragment<u8, N>) -> RlpHeader {
    let mut data = data;
    let first_byte = data.pop_front();

    // Determine the type of RLP-encoded data based on the first byte
    let is_single_byte = first_byte < 0x80;
    let is_small_string = first_byte < 0xb8;
    let is_long_string = first_byte < 0xc0;
    let is_list = first_byte < 0xf8;

    // Calculate the offset to the actual data based on the type
    let offset = if_else(
        is_single_byte,
        0,
        if_else(
            is_small_string,
            1,
            if_else(
                is_long_string,
                wrapping_sub(1 + first_byte, 0xb7) as Field,
                if_else(is_list, 1, wrapping_sub(1 + first_byte, 0xf7) as Field),
            ),
        ),
    );

    // Calculate the length of the length field
    let lenlen = is_long_string as u64
        * (1 - is_small_string as u64)
        * wrapping_sub(first_byte, 0xb7) as u64
        + (1 - is_list as u64) * wrapping_sub(first_byte, 0xf7) as u64;

    // Calculate the actual length of the data
    let len = if_else(
        lenlen == 0,
        if_else(
            is_single_byte,
            1,
            if_else(
                is_small_string,
                wrapping_sub(first_byte, 0x80) as Field,
                wrapping_sub(first_byte, 0xc0) as Field,
            ),
        ),
        get_list_len(data, lenlen) as Field,
    ) as u64;

    let data_type = (first_byte >= 0xc0) as u8;

    RlpHeader::new(offset as u64, len, data_type)
}

/// Decodes RLP-encoded data into a string fragment.
///
/// This function decodes RLP-encoded data that represents a string.
/// It first decodes the header, verifies it's a string, and then
/// creates a fragment representing the string data.
///
/// # Arguments
///
/// * `data` - A fragment containing the RLP-encoded string
///
/// # Returns
///
/// An `RlpFragment` representing the decoded string
///
/// # Panics
///
/// Panics if:
/// - The data is not a string
/// - The total length exceeds the data length
pub fn decode_string<let N: u32>(data: Fragment<u8, N>) -> RlpFragment {
    let mut header = decode_to_rlp_header(data);
    assert(header.is_string(), "Decoded data is not a string");

    let total_len = header.len() + header.offset();
    assert(total_len <= data.len(), "Total length exceeds data length");

    RlpFragment::from_header(header)
}

/// Decodes RLP-encoded data into a list of fragments.
///
/// This function decodes RLP-encoded data that represents a list.
/// It first decodes the header, verifies it's a list, and then
/// recursively decodes each item in the list.
///
/// # Arguments
///
/// * `data` - A fragment containing the RLP-encoded list
/// * `MaxFields` - The maximum number of fields allowed in the list
///
/// # Returns
///
/// An `RlpList` containing the decoded fragments
///
/// # Quirks
/// - For string elements the offset points to the payload
/// - For List elements the offset points to Rlp Header
///
/// # Panics
///
/// Panics if:
/// - The data is not a list
/// - The total length exceeds the data length
/// - The list length doesn't match the total length of items
pub fn decode_list<let N: u32, let MaxFields: u32>(data: Fragment<u8, N>) -> RlpList<MaxFields> {
    let mut rlp_list: RlpList<MaxFields> = BoundedVec::new();

    // Decode the list header
    let header: RlpHeader = decode_to_rlp_header(data);
    assert(header.is_list(), "Decoded data is not a list");

    let total_len = header.len() + header.offset();
    assert(total_len <= data.len(), "Total length exceeds data length");

    // Decode each item in the list
    let mut current_offset = header.offset();
    for _ in 0..MaxFields {
        if (current_offset < total_len) {
            // Get the fragment for the current item
            let item_fragment: Fragment<u8, N> =
                data.sub_fragment(current_offset, data.len() - current_offset);

            // Decode the item's header
            let sub_header: RlpHeader = decode_to_rlp_header(item_fragment);

            let offset = if_else(
                sub_header.data_type() == String,
                (current_offset + sub_header.offset()) as Field,
                (current_offset) as Field,
            ) as u64;

            let length = if_else(
                sub_header.data_type() == List,
                (sub_header.len() + sub_header.offset()) as Field,
                sub_header.len() as Field,
            ) as u64;

            // Add the decoded fragment to the list
            rlp_list.push(RlpFragment::new(offset, length, sub_header.data_type()));

            // Move to the next item
            current_offset += sub_header.offset() + sub_header.len();
        }
    }
    assert(current_offset == total_len, "RLP List length does not match the total length");

    rlp_list
}

mod tests {
    use crate::rlp::list::RlpList;
    use crate::types::fragment::Fragment;
    use super::{decode_list, decode_string, decode_to_rlp_header};

    #[test]
    fn test_decode_single_byte() {
        // Singe byte  66
        let data = Fragment::from_array([0x42]);
        let header = decode_to_rlp_header(data);
        assert(header.is_string());
        assert(header.len() == 1);
        assert(header.offset() == 0);
    }

    #[test]
    fn test_decode_short_string() {
        let data = Fragment::from_array([0x82, 0x01, 0x02]);
        let header = decode_to_rlp_header(data);
        assert(header.is_string());
        assert(header.len() == 2);
        assert(header.offset() == 1);
    }

    #[test]
    fn test_decode_long_string() {
        let data = Fragment::from_array([0xb8, 0x03, 0x01, 0x02, 0x03]);
        let header = decode_to_rlp_header(data);
        assert(header.is_string());
        assert(header.len() == 3);
        assert(header.offset() == 2);
    }

    #[test]
    fn test_decode_short_list() {
        let data = Fragment::from_array([0xc2, 0x01, 0x02]);
        let header = decode_to_rlp_header(data);
        assert(header.is_list());
        assert(header.len() == 2);
        assert(header.offset() == 1);
    }

    #[test]
    fn test_decode_long_list() {
        let data = Fragment::from_array([0xf8, 0x03, 0x01, 0x02, 0x03]);
        let header = decode_to_rlp_header(data);
        assert(header.is_list());
        assert(header.len() == 3);
        assert(header.offset() == 2);
    }

    #[test]
    fn test_decode_nested_list() {
        // Nested + Mixed List
        // ["dog", ["cat", 4], "hello"]
        let data = Fragment::from_array([
            0xd0, 0x83, 0x64, 0x6f, 0x67, 0xc5, 0x83, 0x63, 0x61, 0x74, 0x04, 0x85, 0x68, 0x65,
            0x6c, 0x6c, 0x6f,
        ]);
        let list: RlpList<3> = decode_list(data);

        // Verify list has 3 items
        assert(list.len() == 3);

        // First item: "dog" (string)
        // RLP: 0x83, 0x64, 0x6f, 0x67
        // Offset should point to payload (after length byte i.e 0x64)
        let first = list.get(0);
        assert(first.is_string());
        assert(first.len() == 3);
        assert(first.offset() == 2); // Points to 'd' after length byte

        // Second item: ["cat", 4] (list)
        // RLP: 0xc5, 0x83, 0x63, 0x61, 0x74, 0x04
        // Offset should point to RLP header
        let second = list.get(1);
        assert(second.is_list());
        assert(second.len() == 6); // Total length of list content
        assert(second.offset() == 5); // Points to list header (0xc5)

        // Third item: "hello" (string)
        // RLP: 0x85, 0x68, 0x65, 0x6c, 0x6c, 0x6f
        // Offset should point to payload (after length byte)
        let third = list.get(2);
        assert(third.is_string());
        assert(third.len() == 5);
        assert(third.offset() == 12); // Points to 'h' after length byte
    }

    // #[test]
    // fn test_decode_mixed_list() {
    //     let data = Fragment::from_array([0xc5, 0x82, 0x01, 0x02, 0xc2, 0x03, 0x04]);
    //     let list: RlpList<10> = decode_list(data);
    //     assert(list.len() == 2);
    //     assert(list.get(0).is_string());
    //     assert(list.get(1).is_list());
    // }

    #[test]
    fn test_decode_empty_list() {
        let data = Fragment::from_array([0xc0]);
        let list: RlpList<10> = decode_list(data);
        assert(list.len() == 0);
    }

    #[test]
    fn test_decode_string() {
        let data = Fragment::from_array([0x82, 0x01, 0x02]);
        let fragment = decode_string(data);
        assert(fragment.is_string());
        assert(fragment.len() == 2);
        assert(fragment.offset() == 1);
    }

    #[test]
    fn test_decode_invalid_string() {
        let data = Fragment::from_array([0xc2, 0x01, 0x02]);
        let mut header = decode_to_rlp_header(data);
        assert(!header.is_string());
    }

    #[test]
    fn test_decode_invalid_list() {
        let data = Fragment::from_array([0x82, 0x01, 0x02]);
        let mut header = decode_to_rlp_header(data);
        assert(!header.is_list());
    }

    #[test]
    fn test_decode_max_length() {
        let mut data = [0x42; 0xffff + 3];
        data[0] = 0xb7 + 2;
        data[1] = 0xff;
        data[2] = 0xff;
        let header = decode_to_rlp_header(Fragment::from_array(data));
        assert(header.len() == 0xffff);
    }
}

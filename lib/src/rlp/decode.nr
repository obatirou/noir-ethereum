use super::helpers::read_u64_be;
use std::wrapping_sub;

use crate::helpers::if_else;
use crate::rlp::{fragment::RlpFragment, header::RlpHeader, list::RlpList};
use crate::types::fragment::Fragment;

pub fn decode_to_rlp_header<let N: u32>(data: Fragment<u8, N>) -> RlpHeader {
    let mut data = data;
    let first_byte = data.pop_front();

    let is_single_byte = first_byte < 0x80;
    let is_small_string = first_byte < 0xb8;
    let is_long_string = first_byte < 0xc0;
    let is_list = first_byte < 0xf8;

    let offset = if_else(
        is_single_byte,
        0,
        if_else(
            is_small_string,
            1,
            if_else(
                is_long_string,
                wrapping_sub(1 + first_byte, 0xb7) as Field,
                if_else(is_list, 1, wrapping_sub(1 + first_byte, 0xb7) as Field),
            ),
        ),
    );

    let lenlen = is_long_string as u64
        * (1 - is_small_string as u64)
        * wrapping_sub(first_byte, 0xb7) as u64
        + (1 - is_list as u64) * wrapping_sub(first_byte, 0xf7) as u64;

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
        read_u64_be(data, lenlen) as Field,
    ) as u64;

    RlpHeader::new(offset as u64, len, is_list as u8)
}

pub fn decode_string<let N: u32>(data: Fragment<u8, N>) -> RlpFragment {
    let mut header = decode_to_rlp_header(data);
    assert(header.is_string(), "Decoded data is not a string");

    let total_len = header.len() + header.offset();
    assert(total_len <= data.len(), "Total length exceeds data length");

    RlpFragment::from_header(header)
}

pub fn decode_list<let N: u32, let MaxFields: u32>(data: Fragment<u8, N>) -> RlpList<MaxFields> {
    let mut rlp_list: RlpList<MaxFields> = BoundedVec::new();

    let header: RlpHeader = decode_to_rlp_header(data);
    assert(header.is_list(), "Decoded data is not a list");

    let total_len = header.len() + header.offset();
    assert(total_len <= data.len(), "Total length exceeds data length");

    let mut current_offset = header.offset();
    for _ in 0..MaxFields {
        if (current_offset < total_len) {
            let header: Fragment<u8, N> =
                data.sub_fragment(current_offset, data.len() - current_offset);

            let sub_header: RlpHeader = decode_to_rlp_header(header);

            let mut offset = current_offset;
            let mut length = sub_header.len();
            if (sub_header.is_string()) {
                offset += sub_header.offset();
            } else {
                length += sub_header.offset();
            }

            rlp_list.push(RlpFragment::new(offset, length, sub_header.data_type()));

            current_offset += sub_header.offset() + sub_header.len();
        }
    }
    assert(current_offset == total_len, "RLP List length does not match the total length");

    rlp_list
}

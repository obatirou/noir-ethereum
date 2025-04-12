//! RLP (Recursive Length Prefix) encoding/decoding helper functions.
//!
//! This module provides utilities for working with RLP-encoded data, specifically
//! for handling list length decoding when the first byte is greater than 0xf7.

use crate::types::fragment::Fragment;

/// Maximum number of bytes required to represent length of a  list
/// This means a list will have max length of 2^16 - 1 elements
global MAX_LEN_IN_BYTES: u64 = 2;

/// Decodes the length of an RLP-encoded list when the first byte is > 0xf7.
///
/// # Arguments
///
/// * `data` - A fragment containing the length bytes (after the initial 0xf7 + lenlen byte)
/// * `lenlen` - The number of bytes used to encode the length (first byte - 0xf7)
///
/// # Returns
///
/// The decoded length as a u64 value
///
/// # Panics
///
/// Panics if `lenlen` exceeds `MAX_LEN_IN_BYTES`
pub fn get_list_len<let N: u32>(data: Fragment<u8, N>, lenlen: u64) -> u64 {
    // Ensure length encoding doesn't exceed maximum allowed bytes
    assert(lenlen <= MAX_LEN_IN_BYTES, "Length of length exceeds maximum");

    let mut payload_length = 0;

    for i in 0..MAX_LEN_IN_BYTES {
        if (i < lenlen & i < data.len()) {
            payload_length = data.at(i) as u64 + payload_length * 256;
        }
    }

    payload_length
}

mod tests {
    use crate::rlp::helpers::{get_list_len, MAX_LEN_IN_BYTES};
    use crate::types::fragment::Fragment;

    #[test]
    fn test_list_length_basic() {
        let mut num_elements = 2;
        let mut header = Fragment::from_array([0xf7 + num_elements, 1, 1]);
        let lenlen = (header.pop_front() - 0xf7) as u64;
        assert(get_list_len(header, lenlen) == 0x0101);
    }

    #[test]
    fn test_list_length_padded() {
        let mut num_elements = 2;
        let data = [0xf7 + num_elements, 1, 1];
        let mut header: Fragment<u8, 300> = Fragment::empty().extend_from_array(data);
        let lenlen = (header.pop_front() - 0xf7) as u64;
        assert(get_list_len(header, lenlen) == 0x0101);
    }

    #[test]
    fn test_list_length_max_bytes() {
        let mut num_elements = 2;
        let data = [0xf7 + num_elements, 0xff, 0xff];
        let mut header: Fragment<u8, 300> = Fragment::empty().extend_from_array(data);
        let lenlen = (header.pop_front() - 0xf7) as u64;
        assert(get_list_len(header, lenlen) == 0xffff);
    }

    #[test]
    fn test_list_length_single_byte() {
        let mut num_elements = 1;
        let data = [0xf7 + num_elements, 0x42];
        let mut header = Fragment::from_array(data);
        let lenlen = (header.pop_front() - 0xf7) as u64;
        assert(get_list_len(header, lenlen) == 0x42);
    }

    #[test]
    fn test_list_length_zero() {
        let mut num_elements = 2;
        let data = [0xf7 + num_elements, 0x00, 0x00];
        let mut header: Fragment<u8, 300> = Fragment::empty().extend_from_array(data);
        let lenlen = (header.pop_front() - 0xf7) as u64;
        assert(get_list_len(header, lenlen) == 0x0000);
    }

    #[test]
    fn test_list_length_leading_zeros() {
        let mut num_elements = 2;
        let data = [0xf7 + num_elements, 0x00, 0x42];
        let mut header: Fragment<u8, 300> = Fragment::empty().extend_from_array(data);
        let lenlen = (header.pop_front() - 0xf7) as u64;
        assert(get_list_len(header, lenlen) == 0x0042);
    }

    #[test]
    fn test_list_length_max_allowed_bytes() {
        let mut num_elements = 2;
        let data = [0xf7 + num_elements, 0x01, 0x01];
        let mut header: Fragment<u8, 300> = Fragment::empty().extend_from_array(data);
        let lenlen = (header.pop_front() - 0xf7) as u64;
        assert(lenlen <= MAX_LEN_IN_BYTES, "Length should not exceed maximum allowed bytes");
        assert(get_list_len(header, lenlen) == 0x0101);
    }
}

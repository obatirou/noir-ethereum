//! Helper functions for Merkle Patricia Trie (MPT) verification in Ethereum.
//! This module provides core utilities for working with MPT nodes, including:
//! - Node length calculation and validation
//! - Prefix handling and parity checks
//! - Hash extraction from different node types (branch/extension)
//! - Node hash verification

use std::hash::keccak256;

use crate::helpers::bytes::{byte_to_nibbles, bytes_to_nibbles};
use crate::rlp::{decode::{decode_list_of_small_strings, decode_to_rlp_header}, list::RlpList};
use crate::types::{fragment::Fragment, hash::{Hash, HASH_LEN}};

use super::constants::{BRANCH_NODE_NUM_FIELDS, EXTENSION_NODE_NUM_FIELDS, MAX_NODE_FIELDS};
use super::types::Node;

/// Calculates the actual length of an RLP-encoded node.
/// This function decodes the RLP header of the node and computes its total length
/// including both the header and payload.
///
/// # Arguments
/// * `node` - The RLP-encoded node as a byte array
///
/// # Returns
/// The total length of the node in bytes
///
/// # Panics
/// Panics if the calculated length exceeds the maximum allowed length
pub fn get_node_len<let MaxNodeLen: u32>(node: [u8; MaxNodeLen]) -> u64 {
    let node_header = decode_to_rlp_header(Fragment::from_array(node));
    let node_len = node_header.offset() + node_header.len();
    assert((node_len as u32) <= MaxNodeLen, "Node RLP length exceeds maximum length");

    node_len
}

/// Calculates the parity of a prefix byte.
/// In MPT, prefixes can be 0, 1, 2, or 3, and their parity determines
/// how the key is encoded.
///
/// # Arguments
/// * `prefix` - The prefix byte (must be < 4)
///
/// # Returns
/// 0 for even parity, 1 for odd parity
///
/// # Panics
/// Panics if prefix >= 4
pub fn parity(prefix: u8) -> u64 {
    assert(prefix < 4, "Prefix must be 0, 1, 2 or 3");
    (prefix % 2) as u64
}

/// Checks if a parity value represents even parity.
pub fn is_even_parity(parity: u64) -> bool {
    parity == 0
}

/// Checks if a parity value represents odd parity.
pub fn is_odd_parity(parity: u64) -> bool {
    parity == 1
}

/// Removes the prefix from a key in an MPT node.
/// MPT keys are prefixed with a byte that indicates their type and parity.
/// This function strips this prefix and handles the special case of even parity
/// where an additional zero nibble must be removed.
///
/// # Arguments
/// * `prefixed_key_bytes` - The key bytes with prefix
///
/// # Returns
/// The key bytes without the prefix
///
/// # Panics
/// Panics if the key doesn't follow the expected format
pub fn strip_prefix<let MaxKeyLen: u32>(
    prefixed_key_bytes: Fragment<u8, MaxKeyLen>,
) -> Fragment<u8, MaxKeyLen> {
    let mut nibbles = bytes_to_nibbles(prefixed_key_bytes);

    let prefix = nibbles.pop_front();
    let parity = parity(prefix);
    if (is_even_parity(parity)) {
        assert(nibbles.pop_front() == 0, "Expected a zero after a prefix of even parity");
    }

    nibbles
}

/// Extracts a hash from a branch node in the MPT.
/// Branch nodes contain 16 possible child hashes and a value.
/// This function extracts the hash at the position indicated by the current key nibble.
///
/// # Arguments
/// * `node` - The RLP-encoded node
/// * `node_rlp_list` - The decoded RLP list of the node
/// * `key_nibbles` - The key being looked up
/// * `key_ptr` - Pointer to the current position in the key
///
/// # Returns
/// The hash fragment at the specified position
///
/// # Panics
/// Panics if the expected hash is not found at the specified position
pub fn extract_hash_from_branch_node<let MaxKeyNibbleLen: u32>(
    node: Node,
    node_rlp_list: RlpList<MAX_NODE_FIELDS>,
    key_nibbles: Fragment<u8, MaxKeyNibbleLen>,
    key_ptr: &mut u64,
) -> Fragment<u8, HASH_LEN> {
    let curr_nibble = key_nibbles.at(*key_ptr).into();
    assert(
        node_rlp_list.get(curr_nibble).len() == HASH_LEN.into(),
        "Expected a hash at position given by the key nibble",
    );
    *key_ptr += 1;

    Fragment::new(
        node_rlp_list.get(curr_nibble).offset(),
        (HASH_LEN as u64),
        node,
    )
        .focus()
}

/// Extracts a hash from an extension node in the MPT.
/// Extension nodes contain a shared prefix and a hash to the next node.
/// This function verifies that the extension's prefix matches the current key
/// and extracts the next node's hash.
///
/// # Arguments
/// * `node` - The RLP-encoded node
/// * `node_rlp_list` - The decoded RLP list of the node
/// * `key_nibbles` - The key being looked up
/// * `key_ptr` - Pointer to the current position in the key
///
/// # Returns
/// The hash fragment pointing to the next node
///
/// # Panics
/// Panics if the extension node is invalid or doesn't match the key
pub fn extract_hash_from_extension_node<let MaxKeyNibbleLen: u32>(
    node: Node,
    node_rlp_list: RlpList<MAX_NODE_FIELDS>,
    key_nibbles: Fragment<u8, MaxKeyNibbleLen>,
    key_ptr: &mut u64,
) -> Fragment<u8, HASH_LEN> {
    let prefixed_extension_key_part: Fragment<u8, MaxKeyNibbleLen> = Fragment::new(
        node_rlp_list.get(0).offset(),
        node_rlp_list.get(0).len(),
        node,
    )
        .focus();

    let (prefix, _) = byte_to_nibbles(prefixed_extension_key_part.at(0));
    assert((prefix == 0) | (prefix == 1), "Extension parity prefix must be 0 or 1");
    let extension_key_part = strip_prefix(prefixed_extension_key_part);
    // Extension nodes have a prefix that needs to be removed.
    let curr_key_nibbles_part = key_nibbles.sub_fragment(*key_ptr, extension_key_part.len());
    assert(
        extension_key_part == curr_key_nibbles_part,
        "Extension key part does not correspond to given key nibbles",
    );
    assert(
        node_rlp_list.get(1).len() == HASH_LEN.into(),
        "Expected a hash at the end of the extension node",
    );
    *key_ptr += extension_key_part.len();

    Fragment::new(node_rlp_list.get(1).offset(), HASH_LEN.into(), node).focus()
}

/// Extracts a hash from an MPT node based on its type.
/// This is a high-level function that handles both branch and extension nodes,
/// determining the node type from its RLP structure and delegating to the
/// appropriate extraction function.
///
/// # Arguments
/// * `node` - The RLP-encoded node
/// * `key_nibbles` - The key being looked up
/// * `key_ptr` - Pointer to the current position in the key
///
/// # Returns
/// The hash fragment pointing to the next node
///
/// # Panics
/// Panics if the node type is invalid
pub fn extract_hash<let MaxKeyNibbleLen: u32>(
    node: Node,
    key_nibbles: Fragment<u8, MaxKeyNibbleLen>,
    key_ptr: &mut u64,
) -> Fragment<u8, HASH_LEN> {
    let mut hash = Fragment::from_array([0; HASH_LEN]);
    let node_list: RlpList<MAX_NODE_FIELDS> =
        decode_list_of_small_strings(Fragment::from_array(node));

    if (node_list.len() == BRANCH_NODE_NUM_FIELDS) {
        hash = extract_hash_from_branch_node(node, node_list, key_nibbles, key_ptr);
    } else if (node_list.len() == EXTENSION_NODE_NUM_FIELDS) {
        hash = extract_hash_from_extension_node(node, node_list, key_nibbles, key_ptr);
    } else {
        assert(false, "Invalid node type");
    }

    hash
}

/// Verifies that a node's hash matches its expected value.
/// This function calculates the Keccak-256 hash of the node and compares it
/// with the provided hash.
///
/// # Arguments
/// * `node` - The RLP-encoded node
/// * `hash` - The expected hash value
///
/// # Returns
/// True if the node's hash matches the expected value, false otherwise
pub fn verify_node_hash<let MaxNodeLen: u32>(node: [u8; MaxNodeLen], hash: Hash) -> bool {
    keccak256(node, get_node_len(node) as u32) == hash
}

mod get_node_len {
    use super::get_node_len;

    #[test]
    fn test_get_node_len_valid() {
        // Test with a simple RLP-encoded node (single byte)
        let node = [0x80]; // RLP encoding of empty string
        let len = get_node_len(node);
        assert(len == 1, "Length should be 1 for empty string");

        // Test with a longer RLP-encoded node
        let node = [0x82, 0x01, 0x02]; // RLP encoding of [0x01, 0x02]
        let len = get_node_len(node);
        assert(len == 3, "Length should be 3 for two-byte string");
    }

    #[test(should_fail_with = "Node RLP length exceeds maximum length")]
    fn test_get_node_len_invalid() {
        let node = [0xc2, 0x42];
        let _ = get_node_len(node);
    }
}

mod parity {
    use super::parity;

    #[test]
    fn test_parity_even() {
        assert(parity(0) == 0, "0 should have even parity");
        assert(parity(2) == 0, "2 should have even parity");
    }

    #[test]
    fn test_parity_odd() {
        assert(parity(1) == 1, "1 should have odd parity");
        assert(parity(3) == 1, "3 should have odd parity");
    }

    #[test(should_fail_with = "Prefix must be 0, 1, 2 or 3")]
    fn test_parity_invalid() {
        let _ = parity(4); // Should panic as prefix must be < 4
    }
}

mod strip_prefix {
    use crate::helpers::bytes::byte_to_nibbles;
    use crate::types::fragment::Fragment;
    use super::strip_prefix;

    #[test]
    fn test_strip_prefix__even() {
        let prefixed_key_bytes =
            Fragment::from_array_with_len(3, [0x20, 0xab, 0xcd, 0x00, 0x00, 0x00]);
        let (prefix, _) = byte_to_nibbles(prefixed_key_bytes.at(0));
        assert(prefix == 2, "Incorrect prefix");
        let stripped_nibbles = strip_prefix(prefixed_key_bytes);
        assert(
            stripped_nibbles == Fragment::from_array_with_len(4, [0xa, 0xb, 0xc, 0xd, 0x0, 0x0]),
            "Incorrect stripping of even prefix",
        );
    }

    #[test]
    fn test_strip_prefix_odd() {
        let prefixed_key_bytes =
            Fragment::from_array_with_len(3, [0x3a, 0xbc, 0xde, 0x00, 0x00, 0x00]);
        let (prefix, _) = byte_to_nibbles(prefixed_key_bytes.at(0));
        assert(prefix == 3, "Incorrect prefix");
        let stripped_nibbles = strip_prefix(prefixed_key_bytes);
        assert(
            stripped_nibbles == Fragment::from_array_with_len(5, [0xa, 0xb, 0xc, 0xd, 0xe, 0x0]),
            "Incorrect stripping of odd prefix",
        );
    }

    #[test(should_fail_with = "Expected a zero after a prefix of even parity")]
    fn test_non_zero_after_even_prefix() {
        let wrong_prefix = 0x21;
        let prefixed_key_bytes =
            Fragment::from_array_with_len(3, [wrong_prefix, 0xab, 0xcd, 0x00, 0x00, 0x00]);
        let _ = strip_prefix(prefixed_key_bytes);
    }

    #[test(should_fail_with = "Prefix must be 0, 1, 2 or 3")]
    fn test_invalid_prefix() {
        let prefixed_key_bytes = Fragment::from_array_with_len(2, [0x4a, 0xbc, 0x00, 0x00]);
        let _ = strip_prefix(prefixed_key_bytes);
    }
}

mod extract_hash {
    use crate::mpt::types::Node;
    use crate::types::fragment::Fragment;
    use super::extract_hash;

    #[test(should_fail_with = "Invalid node type")]
    fn fail_invalid_node_type() {
        let mut invalid_node: Node = [0x00; 532];
        invalid_node[0] = 0xc3;
        invalid_node[1] = 0x01;
        invalid_node[2] = 0x02;
        invalid_node[3] = 0x03;
        let mut key_ptr = 0;
        let key_nibbles = Fragment::from_array([]);
        let _ = extract_hash(invalid_node, key_nibbles, &mut key_ptr);
    }
}

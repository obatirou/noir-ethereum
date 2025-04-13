use crate::helpers::bytes::{byte_to_nibbles, bytes_to_nibbles};

use crate::rlp::{decode::decode_to_rlp_header, list::RlpList};
use super::types::Node;

use crate::types::{fragment::Fragment, hash::HASH_LEN};

use crate::rlp::decode::decode_list_of_small_strings;
use crate::types::hash::Hash;
use super::constants::BRANCH_NODE_NUM_FIELDS;
use super::constants::EXTENSION_NODE_NUM_FIELDS;
use super::constants::MAX_NODE_FIELDS;
use std::hash::keccak256;

pub fn get_node_len<let MaxNodeLen: u32>(node: [u8; MaxNodeLen]) -> u64 {
    let node_header = decode_to_rlp_header(Fragment::from_array(node));
    let node_len = node_header.offset() + node_header.len();
    assert((node_len as u32) <= MaxNodeLen, "Node RLP length exceeds maximum length");

    node_len
}

pub fn parity(prefix: u8) -> u64 {
    assert(prefix < 4, "Prefix must be 0, 1, 2 or 3");
    (prefix % 2) as u64
}

pub fn is_even_parity(parity: u64) -> bool {
    parity == 0
}

pub fn is_odd_parity(parity: u64) -> bool {
    parity == 1
}

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
    let extension_key_part = strip_prefix(prefixed_extension_key_part); // Extension nodes have a prefix that needs to be removed.
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

pub fn verify_node_hash<let MaxNodeLen: u32>(node: [u8; MaxNodeLen], hash: Hash) -> bool {
    keccak256(node, get_node_len(node) as u32) == hash
}

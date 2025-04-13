use crate::{rlp::list::RlpList, types::fragment::Fragment};
use super::types::{Leaf, Value};

use crate::helpers::{
    arrays::sub_array_equals_up_to_length,
    bytes::{byte_to_nibbles, bytes_to_nibbles, right_pad},
};
use crate::rlp::decode::decode_list;
use crate::types::hash::Hash;

use super::helpers::{extract_hash, strip_prefix, verify_node_hash};
use super::proof::Proof;
use super::types::Key;

pub fn verify_leaf<let MaxLeafLen: u32, let MaxKeyNibbleLen: u32, let MaxValueLen: u32>(
    leaf: Leaf<MaxLeafLen>,
    key_nibbles: Fragment<u8, MaxKeyNibbleLen>,
    key_ptr: &mut u64,
    value: Value<MaxValueLen>,
) -> bool {
    let leaf_list: RlpList<2> = decode_list(Fragment::from_array(leaf));
    assert(leaf_list.len() == 2, "Leaf expected to have 2 fields");

    let leaf_key: Fragment<u8, MaxKeyNibbleLen> =
        Fragment::new(leaf_list.get(0).offset(), leaf_list.get(0).len(), leaf).focus();

    let (prefix, _) = byte_to_nibbles(leaf_key.at(0));
    assert((prefix == 2) | (prefix == 3), "Leaf parity prefix must be 2 or 3");
    let leaf_key_part: Fragment<u8, MaxKeyNibbleLen> = strip_prefix(leaf_key);
    let left_key_ending: Fragment<u8, MaxKeyNibbleLen> =
        key_nibbles.sub_fragment(*key_ptr, leaf_key_part.len());

    assert(leaf_key_part == left_key_ending, "Key mismatch in the leaf");
    *key_ptr += leaf_key_part.len();
    assert(*key_ptr == key_nibbles.len(), "Expected to consume all key nibbles");

    let value = right_pad(value);
    let value_rlp_fragment = leaf_list.get(1);

    // Verify that extracted value matches the expected value.
    let is_equal_len = value_rlp_fragment.len() == value.len().into();
    let is_equal_data = sub_array_equals_up_to_length(
        value.storage(),
        leaf,
        value_rlp_fragment.offset(),
        value_rlp_fragment.len(),
    );

    is_equal_data & is_equal_len
}

pub fn verify_merkle_proof<let MaxKeyNibbleLen: u32, let MaxValueLen: u32, let MaxDepth: u32, let MaxLeafLen: u32>(
    key: Key<MaxKeyNibbleLen>,
    value: Value<MaxValueLen>,
    root: Hash,
    proof: Proof<MaxDepth, MaxLeafLen>,
) -> bool {
    let key = right_pad(key);
    let key_nibbles = bytes_to_nibbles(Fragment::from_vec(key));
    let mut key_ptr = 0;

    // Verify hashes of all the nodes in the proof path.
    let mut curr_hash = Fragment::from_array(root);
    for i in 0..MaxDepth {
        if i.into() < proof.depth() - 1 {
            let node_verified = verify_node_hash(proof.nodes()[i], curr_hash.data());
            assert(node_verified, f"Invalid node hash at depth {i}");
            curr_hash = extract_hash(proof.nodes()[i], key_nibbles, &mut key_ptr);
        }
    }
    let node_hash_verified = verify_node_hash(proof.leaf(), curr_hash.data());
    let leaf_verified = verify_leaf(proof.leaf(), key_nibbles, &mut key_ptr, value);

    node_hash_verified & leaf_verified
}

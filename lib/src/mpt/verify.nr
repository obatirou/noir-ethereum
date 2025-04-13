//! Verification logic for Merkle Patricia Trie (MPT) proofs in Ethereum.
//! This module provides the core verification functions for MPT proofs, including:
//! - Leaf node verification
//! - Complete proof verification from root to leaf
//!
//! The verification process ensures:
//! - Correct key-value mapping in leaf nodes
//! - Valid hash chain from root to leaf
//! - Proper node structure and encoding

use crate::{rlp::list::RlpList, types::fragment::Fragment};

use crate::helpers::{
    arrays::sub_array_equals_up_to_length,
    bytes::{byte_to_nibbles, bytes_to_nibbles, right_pad},
};
use crate::rlp::decode::decode_list;
use crate::types::hash::Hash;

use super::helpers::{extract_hash, strip_prefix, verify_node_hash};
use super::proof::Proof;
use super::types::{Key, Leaf, Value};

/// Verifies a leaf node in the Merkle Patricia Trie.
/// This function checks that:
/// 1. The leaf node has the correct structure (2 fields)
/// 2. The key in the leaf matches the expected key
/// 3. The value in the leaf matches the expected value
///
/// # Arguments
/// * `leaf`: The leaf node to verify
/// * `key_nibbles`: The expected key in nibble form
/// * `key_ptr`: Pointer to track position in the key
/// * `value`: The expected value
///
/// # Returns
/// True if the leaf node is valid, false otherwise
///
/// # Panics
/// Panics if the leaf node structure is invalid or key mismatch is detected
pub fn verify_leaf<let MaxLeafLen: u32, let MaxKeyNibbleLen: u32, let MaxValueLen: u32>(
    leaf: Leaf<MaxLeafLen>,
    key_nibbles: Fragment<u8, MaxKeyNibbleLen>,
    key_ptr: &mut u64,
    value: Value<MaxValueLen>,
) -> bool {
    // Decode the leaf node into its RLP components
    let leaf_list: RlpList<2> = decode_list(Fragment::from_array(leaf));
    assert(leaf_list.len() == 2, "Leaf expected to have 2 fields");

    // Extract and verify the leaf key
    let leaf_key: Fragment<u8, MaxKeyNibbleLen> =
        Fragment::new(leaf_list.get(0).offset(), leaf_list.get(0).len(), leaf).focus();

    // Verify leaf key prefix (must be 2 or 3 for leaf nodes)
    let (prefix, _) = byte_to_nibbles(leaf_key.at(0));
    assert((prefix == 2) | (prefix == 3), "Leaf parity prefix must be 2 or 3");

    // Strip prefix and verify key match
    let leaf_key_part: Fragment<u8, MaxKeyNibbleLen> = strip_prefix(leaf_key);
    let left_key_ending: Fragment<u8, MaxKeyNibbleLen> =
        key_nibbles.sub_fragment(*key_ptr, leaf_key_part.len());

    assert(leaf_key_part == left_key_ending, "Key mismatch in the leaf");
    *key_ptr += leaf_key_part.len();
    assert(*key_ptr == key_nibbles.len(), "Expected to consume all key nibbles");

    // Verify value match
    let value = right_pad(value);
    let value_rlp_fragment = leaf_list.get(1);

    // Check both length and content match
    let is_equal_len = value_rlp_fragment.len() == value.len().into();
    let is_equal_data = sub_array_equals_up_to_length(
        value.storage(),
        leaf,
        value_rlp_fragment.offset(),
        value_rlp_fragment.len(),
    );

    is_equal_data & is_equal_len
}

/// Verifies a complete Merkle Patricia Trie proof.
/// This function performs a complete verification of the proof by:
/// 1. Converting the key to nibbles
/// 2. Verifying the hash chain from root to leaf
/// 3. Verifying the leaf node contents
///
/// # Arguments
/// * `key`: The key being looked up
/// * `value`: The expected value for the key
/// * `root`: The root hash of the trie
/// * `proof`: The proof to verify
///
/// # Returns
/// True if the proof is valid, false otherwise
///
/// # Panics
/// Panics if any node in the proof path has an invalid hash
pub fn verify_merkle_proof<let MaxKeyNibbleLen: u32, let MaxValueLen: u32, let MaxDepth: u32, let MaxLeafLen: u32>(
    key: Key<MaxKeyNibbleLen>,
    value: Value<MaxValueLen>,
    root: Hash,
    proof: Proof<MaxDepth, MaxLeafLen>,
) -> bool {
    // Prepare key for verification
    let key = right_pad(key);
    let key_nibbles = bytes_to_nibbles(Fragment::from_vec(key));
    let mut key_ptr = 0;

    // Start verification from root hash
    let mut curr_hash = Fragment::from_array(root);

    // Verify each node in the proof path
    for i in 0..MaxDepth {
        if i.into() < proof.depth() - 1 {
            // Verify current node's hash matches expected hash
            let node_verified = verify_node_hash(proof.nodes()[i], curr_hash.data());
            assert(node_verified, f"Invalid node hash at depth {i}");

            // Extract next hash in the path
            curr_hash = extract_hash(proof.nodes()[i], key_nibbles, &mut key_ptr);
        }
    }

    // Verify final leaf node
    let node_hash_verified = verify_node_hash(proof.leaf(), curr_hash.data());
    let leaf_verified = verify_leaf(proof.leaf(), key_nibbles, &mut key_ptr, value);

    // Both hash chain and leaf contents must be valid
    node_hash_verified & leaf_verified
}

mod verify_merkle_tree_tests {
    use crate::fixtures::mpt::leaf_large::{key, proof_input, root, value};
    use crate::fixtures::mpt::leaf_small::{key as k, proof_input as input, root as r, value as v};

    #[test]
    fn test_verify_merkle_proof_small() {
        assert(super::verify_merkle_proof(key, value, root, proof_input.proof()));
    }

    #[test]
    fn test_verify_merkle_proof_large() {
        assert(super::verify_merkle_proof(k, v, r, input.proof()));
    }
}

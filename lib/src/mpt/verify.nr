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

use crate::fixtures::mpt::leaf_small::leaf;
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
/// # Panics
/// Panics if the leaf node structure is invalid or key mismatch is detected
pub fn verify_leaf<let MaxLeafLen: u32, let MaxKeyNibbleLen: u32, let MaxValueLen: u32>(
    leaf: Leaf<MaxLeafLen>,
    key_nibbles: Fragment<u8, MaxKeyNibbleLen>,
    key_ptr: &mut u64,
    value: Value<MaxValueLen>,
) {
    // Decode the leaf node into its RLP components
    let leaf_list: RlpList<2> = decode_list(Fragment::from_array(leaf));
    assert(leaf_list.len() == 2, "Leaf expected to have 2 fields");

    let encoded_path_component = leaf_list.get(0);

    // Extract the Path component
    let path_fragment: Fragment<u8, MaxKeyNibbleLen> = Fragment::new(
        encoded_path_component.offset(),
        encoded_path_component.len(),
        leaf,
    )
        .focus();

    // Decode First byte of encoded path.
    // 0: Extension node with even-length path.
    // 1: Extension node with odd-length path.
    // 2: Leaf node with even-length path.
    // 3: Leaf node with odd-length path.
    let (prefix, _) = byte_to_nibbles(path_fragment.at(0));
    assert((prefix == 2) | (prefix == 3), "Leaf parity prefix must be 2 or 3");

    // Strip Prefix and padding if even parity
    let leaf_key_part: Fragment<u8, MaxKeyNibbleLen> = strip_prefix(path_fragment);

    let left_key_ending: Fragment<u8, MaxKeyNibbleLen> =
        key_nibbles.sub_fragment(*key_ptr, leaf_key_part.len());

    assert(leaf_key_part == left_key_ending, "Key mismatch in the leaf");

    // Update key pointer to end of the key
    *key_ptr += leaf_key_part.len();

    assert(*key_ptr == key_nibbles.len(), "Expected to consume all key nibbles");

    // Verify value match
    let value = right_pad(value);
    let value_rlp_fragment = leaf_list.get(1);

    // Check both length and content match
    assert(value_rlp_fragment.len() == value.len().into(), "Value length mismatch");
    assert(
        sub_array_equals_up_to_length(
            value.storage(),
            leaf,
            value_rlp_fragment.offset(),
            value_rlp_fragment.len(),
        ),
        "Value data mismatch",
    );
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
///
/// # Panics
/// Panics if any node in the proof path has an invalid hash
pub fn verify_merkle_proof<let MaxKeyNibbleLen: u32, let MaxValueLen: u32, let MaxDepth: u32, let MaxLeafLen: u32>(
    key: Key<MaxKeyNibbleLen>,
    value: Value<MaxValueLen>,
    root: Hash,
    proof: Proof<MaxDepth, MaxLeafLen>,
) {
    // Prepare key for verification
    let key = right_pad(key);
    let key_nibbles = bytes_to_nibbles(Fragment::from_vec(key));
    let mut key_ptr = 0;

    // Start verification from root hash
    let mut curr_hash = Fragment::from_array(root);

    // Verify each node in the proof path
    for i in 0..MaxDepth {
        if (i as u64) < proof.depth() - 1 {
            // Verify current node's hash matches expected hash
            verify_node_hash(proof.nodes()[i], curr_hash.data());

            // Extract next hash in the path
            curr_hash = extract_hash(proof.nodes()[i], key_nibbles, &mut key_ptr);
        }
    }

    // Verify final leaf node
    verify_node_hash(proof.leaf(), curr_hash.data());
    verify_leaf(proof.leaf(), key_nibbles, &mut key_ptr, value);
}

mod verify_merkle_tree_tests {
    use super::verify_merkle_proof;

    use crate::fixtures::mpt::leaf_large::{
        key as leaf_large_key, proof_input as leaf_large_input, root as leaf_large_root,
        value as leaf_large_value,
    };

    use crate::fixtures::mpt::leaf_small::{
        key as leaf_small_key, proof_input as leaf_small_input, root as leaf_small_root,
        value as leaf_small_value,
    };

    use crate::fixtures::mpt::extension_even::{
        key as extension_even_key, proof_input as extension_even_input, root as extension_even_root,
        value as extension_even_value,
    };

    use crate::fixtures::mpt::extension_odd::{
        key as extension_odd_key, proof_input as extension_odd_input, root as extension_odd_root,
        value as extension_odd_value,
    };

    #[test]
    fn test_verify_merkle_proof_large() {
        verify_merkle_proof(
            leaf_large_key,
            leaf_large_value,
            leaf_large_root,
            leaf_large_input.proof(),
        );
    }

    #[test]
    fn test_verify_merkle_proof_small() {
        verify_merkle_proof(
            leaf_small_key,
            leaf_small_value,
            leaf_small_root,
            leaf_small_input.proof(),
        );
    }

    #[test]
    fn test_verify_merkle_proof_extension_even() {
        verify_merkle_proof(
            extension_even_key,
            extension_even_value,
            extension_even_root,
            extension_even_input.proof(),
        );
    }

    #[test]
    fn test_verify_merkle_proof_extension_odd() {
        verify_merkle_proof(
            extension_odd_key,
            extension_odd_value,
            extension_odd_root,
            extension_odd_input.proof(),
        );
    }
}

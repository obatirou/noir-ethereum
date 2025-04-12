//! RLP (Recursive Length Prefix) List type definition.
//!
//! This module provides a type definition for RLP-encoded lists.
//! Lists in RLP are collections of RLP-encoded items, where each item
//! can be either a string or another list.

use super::fragment::RlpFragment;

/// A type alias for a bounded vector of RLP fragments representing an RLP list.
///
/// An RLP list is a collection of RLP-encoded items, where each item
/// is represented by an `RlpFragment`. The list has a maximum number of
/// fields specified by the `MAX_FIELDS` generic parameter.
///
/// # Type Parameters
///
/// * `MAX_FIELDS` - The maximum number of fields allowed in the list
///
/// # Examples
///
/// ```
/// // Create a list with maximum 10 fields
/// let mut list: RlpList<10> = BoundedVec::new();
///
/// // Add a string fragment
/// list.push(RlpFragment::new(0, 5, String));
///
/// // Add a list fragment
/// list.push(RlpFragment::new(5, 10, List));
/// ```
///
/// # RLP Encoding
///
/// In RLP encoding, lists are encoded as:
/// 1. A single byte if the total payload length is 0-55 bytes
/// 2. A length-of-length byte followed by the length if the payload is longer
///
/// The list's contents are the concatenation of the RLP encodings of its items.
pub type RlpList<let MAX_FIELDS: u32> = BoundedVec<RlpFragment, MAX_FIELDS>;

mod tests {
    use crate::rlp::constants::{List, String};
    use crate::rlp::fragment::RlpFragment;
    use crate::rlp::list::RlpList;

    #[test]
    fn test_list_creation() {
        let mut list: RlpList<10> = BoundedVec::new();
        assert(list.len() == 0);
    }

    #[test]
    fn test_list_push() {
        let mut list: RlpList<10> = BoundedVec::new();
        let fragment = RlpFragment::new(0, 5, String);
        list.push(fragment);
        assert(list.len() == 1);
        assert(list.get(0).is_string());
    }

    #[test]
    fn test_list_max_fields() {
        let mut list: RlpList<3> = BoundedVec::new();
        let fragment1 = RlpFragment::new(0, 5, String);
        let fragment2 = RlpFragment::new(5, 5, List);
        let fragment3 = RlpFragment::new(10, 5, String);

        list.push(fragment1);
        list.push(fragment2);
        list.push(fragment3);

        assert(list.len() == 3);
    }

    #[test]
    fn test_list_mixed_types() {
        let mut list: RlpList<5> = BoundedVec::new();
        let string_fragment = RlpFragment::new(0, 5, String);
        let list_fragment = RlpFragment::new(5, 10, List);

        list.push(string_fragment);
        list.push(list_fragment);

        assert(list.len() == 2);
        assert(list.get(0).is_string());
        assert(list.get(1).is_list());
    }

    #[test]
    fn test_list_empty_fragments() {
        let mut list: RlpList<5> = BoundedVec::new();
        let empty_fragment = RlpFragment::new(0, 0, String);

        list.push(empty_fragment);
        assert(list.len() == 1);
        assert(list.get(0).is_empty());
    }

    #[test]
    fn test_list_contiguous_fragments() {
        let mut list: RlpList<5> = BoundedVec::new();
        let fragment1 = RlpFragment::new(0, 5, String);
        let fragment2 = RlpFragment::new(5, 5, String);

        list.push(fragment1);
        list.push(fragment2);

        assert(list.len() == 2);
        assert(list.get(0).end() == list.get(1).offset());
    }
}

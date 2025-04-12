//! RLP (Recursive Length Prefix) Header structure and operations.
//!
//! This module provides a data structure for representing RLP headers.
//! A header contains metadata about RLP-encoded data, including its position,
//! length, and type (string or list).

use crate::helpers::if_else;
use super::constants::{List, String};

/// Represents an RLP header containing metadata about encoded data.
///
/// A header contains three pieces of metadata:
/// - `offset`: The starting position of the encoded data
/// - `length`: The length of the encoded data in bytes
/// - `data_type`: Whether the data is a string (0) or list (1)
///
/// Headers are used to efficiently navigate and manipulate RLP-encoded data
/// without needing to decode the entire payload.
pub struct RlpHeader {
    offset: u64,
    length: u64,
    data_type: u8,
}

impl RlpHeader {
    /// Creates a new RLP header with the given metadata.
    ///
    /// # Arguments
    ///
    /// * `offset` - The starting position of the encoded data
    /// * `length` - The length of the encoded data in bytes
    /// * `data_type` - The type of the encoded data (String or List)
    ///
    /// # Returns
    ///
    /// A new RLP header with the specified metadata
    pub fn new(offset: u64, length: u64, data_type: u8) -> Self {
        Self { offset, length, data_type }
    }

    /// Checks if the header represents a string.
    ///
    /// # Returns
    ///
    /// `true` if the header is for a string, `false` otherwise
    pub fn is_string(self) -> bool {
        self.data_type == String
    }

    /// Checks if the header represents a list.
    ///
    /// # Returns
    ///
    /// `true` if the header is for a list, `false` otherwise
    pub fn is_list(self) -> bool {
        self.data_type == List
    }

    /// Checks if the header represents empty data.
    ///
    /// # Returns
    ///
    /// `true` if the length is zero, `false` otherwise
    pub fn is_empty(self) -> bool {
        self.length == 0
    }

    /// Gets the length of the encoded data in bytes.
    ///
    /// # Returns
    ///
    /// The length of the encoded data in bytes
    pub fn len(self) -> u64 {
        self.length
    }

    /// Gets the offset of the encoded data.
    ///
    /// # Returns
    ///
    /// The starting position of the encoded data
    pub fn offset(self) -> u64 {
        self.offset
    }

    /// Gets the data type of the encoded data.
    ///
    /// # Returns
    ///
    /// The type of the encoded data (String or List)
    pub fn data_type(self) -> u8 {
        self.data_type
    }

    /// Gets the end position of the encoded data.
    ///
    /// # Returns
    ///
    /// The position immediately after the end of the encoded data
    pub fn end(self) -> u64 {
        self.offset + self.length
    }

    /// Checks if the header is valid.
    ///
    /// A header is valid if:
    /// - The data type is either String or List
    /// - The length is non-negative
    ///
    /// # Returns
    ///
    /// `true` if the header is valid, `false` otherwise
    pub fn is_valid(self) -> bool {
        let valid_type = (self.data_type == String) | (self.data_type == List);
        let valid_length = self.length >= 0;
        valid_type & valid_length
    }

    /// Checks if the header's data is within specified bounds.
    ///
    /// # Arguments
    ///
    /// * `max_length` - The maximum allowed length
    ///
    /// # Returns
    ///
    /// `true` if the data is within bounds, `false` otherwise
    pub fn is_within_bounds(self, max_length: u64) -> bool {
        self.end() <= max_length
    }

    /// Checks if this header's data is contiguous with another header's data.
    ///
    /// Two headers are contiguous if the end of one's data is the start of the other's.
    ///
    /// # Arguments
    ///
    /// * `other` - The other header to check
    ///
    /// # Returns
    ///
    /// `true` if the headers are contiguous, `false` otherwise
    pub fn is_contiguous(self, other: Self) -> bool {
        self.end() == other.offset
    }

    /// Checks if this header's data overlaps with another header's data.
    ///
    /// Two headers overlap if their data ranges share any positions.
    ///
    /// # Arguments
    ///
    /// * `other` - The other header to check
    ///
    /// # Returns
    ///
    /// `true` if the headers overlap, `false` otherwise
    pub fn overlaps(self, other: Self) -> bool {
        let self_end = self.end();
        let other_end = other.end();
        ((self.offset <= other.offset) & (self_end > other.offset))
            | ((other.offset <= self.offset) & (other_end > self.offset))
    }

    /// Checks if this header's data contains another header's data.
    ///
    /// A header A contains header B if B's data range is completely within A's.
    ///
    /// # Arguments
    ///
    /// * `other` - The other header to check
    ///
    /// # Returns
    ///
    /// `true` if this header contains the other, `false` otherwise
    pub fn contains(self, other: Self) -> bool {
        let self_end = self.end();
        let other_end = other.end();
        (self.offset <= other.offset) & (self_end >= other_end)
    }

    /// Merges this header with another header.
    ///
    /// Creates a new header that spans both headers' data ranges.
    /// The data type of the first header is preserved.
    ///
    /// # Arguments
    ///
    /// * `other` - The other header to merge with
    ///
    /// # Returns
    ///
    /// A new header spanning both headers' data ranges
    pub fn merge(self, other: Self) -> Self {
        let new_offset = if_else(
            self.offset < other.offset,
            self.offset as Field,
            other.offset as Field,
        ) as u64;
        let new_end = if_else(
            self.end() > other.end(),
            self.end() as Field,
            other.end() as Field,
        ) as u64;
        let new_length = new_end - new_offset;
        Self::new(new_offset, new_length, self.data_type)
    }
}

impl Eq for RlpHeader {
    /// Checks if two headers are equal.
    ///
    /// Two headers are equal if they have the same offset, length, and data type.
    ///
    /// # Arguments
    ///
    /// * `other` - The other header to compare with
    ///
    /// # Returns
    ///
    /// `true` if the headers are equal, `false` otherwise
    fn eq(self, other: Self) -> bool {
        (self.offset == other.offset)
            & (self.length == other.length)
            & (self.data_type == other.data_type)
    }
}

mod tests {
    use crate::rlp::constants::{List, String};
    use crate::rlp::header::RlpHeader;

    #[test]
    fn test_header_creation() {
        let header = RlpHeader::new(0, 10, String);
        assert(header.is_string());
        assert(!header.is_list());
        assert(header.len() == 10);
        assert(header.offset() == 0);
        assert(header.end() == 10);
    }

    #[test]
    fn test_empty_header() {
        let header = RlpHeader::new(0, 0, String);
        assert(header.is_empty());
        assert(header.is_valid());
        assert(header.end() == 0);
    }

    #[test]
    fn test_header_contains() {
        let outer = RlpHeader::new(0, 10, String);
        let inner = RlpHeader::new(2, 5, String);
        assert(outer.contains(inner));
        assert(!inner.contains(outer));
    }

    #[test]
    fn test_header_overlaps() {
        let a = RlpHeader::new(0, 5, String);
        let b = RlpHeader::new(3, 5, String);
        assert(a.overlaps(b));
        assert(b.overlaps(a));
    }

    #[test]
    fn test_header_no_overlap() {
        let a = RlpHeader::new(0, 3, String);
        let b = RlpHeader::new(4, 3, String);
        assert(!a.overlaps(b));
        assert(!b.overlaps(a));
    }

    #[test]
    fn test_header_contiguous() {
        let a = RlpHeader::new(0, 5, String);
        let b = RlpHeader::new(5, 5, String);
        assert(a.is_contiguous(b));
        assert(!b.is_contiguous(a));
    }

    #[test]
    fn test_header_equality() {
        let a = RlpHeader::new(0, 10, String);
        let b = RlpHeader::new(0, 10, String);
        let c = RlpHeader::new(1, 10, String);
        let d = RlpHeader::new(0, 11, String);
        let e = RlpHeader::new(0, 10, List);

        assert(a == b);
        assert(a != c);
        assert(a != d);
        assert(a != e);
    }

    #[test]
    fn test_header_validity() {
        let valid_string = RlpHeader::new(0, 10, String);
        let valid_list = RlpHeader::new(0, 10, List);
        let empty = RlpHeader::new(0, 0, String);
        let invalid_type = RlpHeader::new(0, 10, 2);

        assert(valid_string.is_valid());
        assert(valid_list.is_valid());
        assert(empty.is_valid());
        assert(!invalid_type.is_valid());
    }

    #[test]
    fn test_header_within_bounds() {
        let header = RlpHeader::new(0, 10, String);
        assert(header.is_within_bounds(10));
        assert(header.is_within_bounds(15));
        assert(!header.is_within_bounds(5));
    }

    #[test]
    fn test_header_merge() {
        let a = RlpHeader::new(0, 5, String);
        let b = RlpHeader::new(3, 5, String);
        let merged = a.merge(b);

        assert(merged.offset() == 0);
        assert(merged.end() == 8);
        assert(merged.len() == 8);
        assert(merged.is_string());
    }

    #[test]
    fn test_header_boundary_conditions() {
        let max_offset = RlpHeader::new(0xffffffffffffffff, 1, String);
        assert(max_offset.is_valid());
        assert(max_offset.end() == 0xffffffffffffffff + 1);
    }

    #[test]
    fn test_header_merge_reversed() {
        let a = RlpHeader::new(3, 5, String);
        let b = RlpHeader::new(0, 5, String);
        let merged = a.merge(b);

        assert(merged.offset() == 0);
        assert(merged.end() == 8);
        assert(merged.len() == 8);
        assert(merged.is_string());
    }

    #[test]
    fn test_header_merge_different_types() {
        let a = RlpHeader::new(0, 5, String);
        let b = RlpHeader::new(3, 5, List);
        let merged = a.merge(b);

        assert(merged.is_string()); // Should preserve first header's type
    }
}

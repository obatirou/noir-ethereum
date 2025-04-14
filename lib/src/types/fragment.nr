//! A generic fragment data structure for representing a portion of an array.
//!
//! The `Fragment` struct provides a way to represent and manipulate a portion of an array
//! while maintaining the original data. It is particularly useful for working with
//! slices of data without copying the underlying array.
//!
//! # Type Parameters
//!
//! * `T` - The type of elements stored in the fragment
//! * `MaxLen` - The maximum length of the underlying array

use crate::helpers::arrays::memcpy_up_to_length;
use crate::helpers::iterator::Iterator;
use std::mem::zeroed;

/// A fragment represents a portion of an array with metadata about its position and length.
///
/// The fragment maintains an offset into the original data array and a length,
/// allowing operations to be performed on the subset of data without copying.
pub struct Fragment<T, let MaxLen: u32> {
    /// The starting position of the fragment in the original data array
    offset: u64,
    /// The length of the fragment
    length: u64,
    /// The underlying data array
    data: [T; MaxLen],
}

impl<T, let MaxLen: u32> Fragment<T, MaxLen> {
    /// Creates a new fragment with the given metadata.
    ///
    /// # Arguments
    ///
    /// * `offset` - The starting position in the original data
    /// * `length` - The length of the fragment
    /// * `data` - The underlying data array
    ///
    /// # Panics
    ///
    /// Panics if `offset + length` exceeds the length of the data array
    pub fn new(offset: u64, length: u64, data: [T; MaxLen]) -> Self {
        assert(
            offset + length <= data.len() as u64,
            "Offset and length exceed the length of the data",
        );
        Self { offset, length, data }
    }

    /// Creates a fragment from an array, using the entire array as the fragment.
    ///
    /// # Arguments
    ///
    /// * `data` - The array to create a fragment from
    pub fn from_array(data: [T; MaxLen]) -> Self {
        Self::new(0, data.len() as u64, data)
    }

    /// Creates a fragment from a bounded vector, using the entire vector as the fragment.
    ///
    /// # Arguments
    ///
    /// * `vec` - The bounded vector to create a fragment from
    pub fn from_bounded_vec(vec: BoundedVec<T, MaxLen>) -> Self {
        Self::new(0, MaxLen as u64, vec.storage())
    }

    /// Creates a fragment from a bounded vector, using the vector's actual length.
    ///
    /// # Arguments
    ///
    /// * `vec` - The bounded vector to create a fragment from
    pub fn from_vec(vec: BoundedVec<T, MaxLen>) -> Self {
        Fragment { offset: 0, length: vec.len().into(), data: vec.storage() }
    }

    /// Creates a fragment from an array with a specified length.
    ///
    /// # Arguments
    ///
    /// * `length` - The length of the fragment
    /// * `data` - The array to create a fragment from
    ///
    /// # Panics
    ///
    /// Panics if `length` exceeds the length of the data array
    pub fn from_array_with_len(length: u64, data: [T; MaxLen]) -> Self {
        assert(length <= data.len() as u64, "Fragment length exceeds data length");

        Fragment { offset: 0, length, data }
    }

    /// Extends the fragment by appending elements from an array.
    ///
    /// # Arguments
    ///
    /// * `array` - The array to append
    ///
    /// # Panics
    ///
    /// Panics if the new length would exceed the maximum fragment length
    pub fn extend_from_array<let N: u32>(&mut self, array: [T; N]) -> Self {
        let new_length = self.length + array.len() as u64;
        assert(new_length <= MaxLen as u64, "Extended length exceeds maximum fragment length");

        for i in 0..N {
            self.data[self.end() as u32 + i] = array[i];
        }
        self.length = new_length;
        *self
    }

    /// Extends the fragment by appending elements from a bounded vector.
    ///
    /// # Arguments
    ///
    /// * `vec` - The bounded vector to append
    ///
    /// # Panics
    ///
    /// Panics if the new length would exceed the maximum fragment length
    pub fn extend_from_bounded_vec<let N: u32>(&mut self, vec: BoundedVec<T, N>) -> Self {
        let new_length = self.length + vec.len() as u64;
        assert(new_length <= MaxLen as u64, "Extended length exceeds maximum fragment length");

        for i in 0..vec.len() {
            self.data[self.end() as u32 + i] = vec.get(i);
        }
        self.length = new_length;
        *self
    }

    /// Returns the length of the fragment.
    pub fn len(self) -> u64 {
        self.length
    }

    /// Returns the underlying data array.
    pub fn data(self) -> [T; MaxLen] {
        self.data
    }

    /// Returns the offset of the fragment.
    pub fn offset(self) -> u64 {
        self.offset
    }

    /// Creates an empty fragment with zeroed data.
    pub fn empty() -> Self {
        Self { offset: 0, length: 0, data: zeroed() }
    }

    /// Checks if the fragment is empty.
    pub fn is_empty(self) -> bool {
        self.length == 0
    }

    /// Returns the element at the specified index.
    ///
    /// # Arguments
    ///
    /// * `index` - The index of the element to retrieve
    ///
    /// # Panics
    ///
    /// Panics if `index` is out of bounds
    pub fn at(self, index: u64) -> T {
        assert(index < self.length, "Index out of bounds");
        self.data[self.offset + index]
    }

    /// Sets the element at the specified index.
    ///
    /// # Arguments
    ///
    /// * `index` - The index of the element to set
    /// * `value` - The new value
    ///
    /// # Panics
    ///
    /// Panics if `index` is out of bounds
    pub fn set(&mut self, index: u64, value: T) {
        let length = self.length;
        assert(
            index < self.length,
            f"Index out of bounds, tried to set at index {index} but the length is {length}",
        );

        self.data[self.offset + index] = value;
    }

    /// Creates a sub-fragment from this fragment.
    ///
    /// # Arguments
    ///
    /// * `offset` - The offset from the start of this fragment
    /// * `length` - The length of the sub-fragment
    ///
    /// # Panics
    ///
    /// Panics if `offset + length` exceeds the length of this fragment
    pub fn sub_fragment(self, offset: u64, length: u64) -> Fragment<T, MaxLen> {
        assert(offset + length <= self.length, "Offset and length exceed the length of the data");
        Fragment { offset: self.offset + offset, length, data: self.data }
    }

    /// Creates a new fragment with a different maximum length.
    ///
    /// # Generics
    ///
    /// * `NewMaxLen` - The new maximum length
    ///
    /// # Panics
    ///
    /// Panics if `NewMaxLen` is smaller than the current fragment length
    pub fn focus<let NewMaxLen: u32>(self) -> Fragment<T, NewMaxLen> {
        assert((NewMaxLen as u64) >= self.length, "New max length is smaller than fragment length");

        let mut new_data: [T; NewMaxLen] = zeroed();
        memcpy_up_to_length(&mut new_data, self.data, self.offset, self.length);

        Fragment { offset: 0, length: self.length, data: new_data }
    }

    /// Returns the end position of the fragment in the original data array.
    pub fn end(self) -> u64 {
        self.offset + self.length
    }

    /// Checks if the fragment is valid.
    ///
    /// A fragment is valid if its length is non-negative and its end position
    /// does not exceed the length of the data array.
    pub fn is_valid(self) -> bool {
        let valid_length = self.length >= 0;
        let within_bounds = self.end() <= self.data.len() as u64;
        valid_length & within_bounds
    }

    /// Checks if the fragment is within the specified maximum length.
    ///
    /// # Arguments
    ///
    /// * `max_length` - The maximum allowed length
    pub fn is_within_bounds(self, max_length: u64) -> bool {
        self.end() <= max_length
    }

    /// Creates a slice of the fragment.
    ///
    /// # Arguments
    ///
    /// * `start` - The starting index
    /// * `end` - The ending index (exclusive)
    ///
    /// # Panics
    ///
    /// Panics if `start` is greater than `end` or if `end` exceeds the fragment length
    pub fn slice(self, start: u64, end: u64) -> Self {
        assert(start <= end, "Start must be less than or equal to end");
        assert(end <= self.length, "End must be less than or equal to length");
        Self::new(self.offset + start, end - start, self.data)
    }

    /// Returns the first element of the fragment.
    ///
    /// # Panics
    ///
    /// Panics if the fragment is empty
    pub fn first(self) -> T {
        assert(!self.is_empty(), "Fragment is empty");
        self.data[self.offset]
    }

    /// Returns the last element of the fragment.
    ///
    /// # Panics
    ///
    /// Panics if the fragment is empty
    pub fn last(self) -> T {
        assert(!self.is_empty(), "Fragment is empty");
        self.data[self.end() - 1]
    }

    /// Appends an element to the end of the fragment.
    ///
    /// # Arguments
    ///
    /// * `value` - The value to append
    ///
    /// # Panics
    ///
    /// Panics if the fragment is full
    pub fn push_back(&mut self, value: T) -> Self {
        assert(self.end() < self.data.len() as u64, "Fragment is full");
        self.data[self.end()] = value;
        self.length += 1;
        *self
    }

    /// Removes and returns the last element of the fragment.
    ///
    /// # Panics
    ///
    /// Panics if the fragment is empty
    pub fn pop_back(&mut self) -> T {
        assert(!self.is_empty(), "Fragment is empty");
        self.length -= 1;
        self.data[self.end()]
    }

    /// Removes and returns the first element of the fragment.
    ///
    /// # Panics
    ///
    /// Panics if the fragment is empty
    pub fn pop_front(&mut self) -> T {
        assert(self.length > 0, "Fragment is empty");
        self.offset += 1;
        self.length -= 1;
        self.data[self.offset - 1]
    }

    /// Prepends an element to the beginning of the fragment.
    ///
    /// # Arguments
    ///
    /// * `value` - The value to prepend
    ///
    /// # Panics
    ///
    /// Panics if the fragment is empty
    pub fn push_front(&mut self, value: T) -> Self {
        assert(self.offset > 0, "Fragment is empty");
        self.offset -= 1;
        self.length += 1;
        self.data[self.offset] = value;
        *self
    }

    /// Checks if this fragment is equal to another fragment.
    ///
    /// # Arguments
    ///
    /// * `other` - The fragment to compare with
    ///
    /// # Returns
    ///
    /// `true` if the fragments have the same length and elements, `false` otherwise
    pub fn eq<let OtherMaxLen: u32>(self, other: Fragment<T, OtherMaxLen>) -> bool
    where
        T: Eq,
    {
        let res = &mut true;
        if (self.length != other.length) {
            *res = false;
        }
        self.each(|el, i| {
            if i < other.length {
                *res &= el == other.at(i);
            }
        });

        *res
    }
}

impl<T, let MaxLen: u32> Iterator<T> for Fragment<T, MaxLen> {
    /// Iterates over the elements of the fragment.
    ///
    /// # Arguments
    ///
    /// * `f` - The function to apply to each element
    fn each<Env>(self, f: fn[Env](T, u64) -> ()) {
        for i in 0..MaxLen {
            if (i as u64) < self.len() {
                f(self.at(i as u64), i as u64);
            }
        }
    }
}

impl<T, let MaxLen: u32> Eq for Fragment<T, MaxLen>
where
    T: Eq,
{
    /// Checks if two fragments are equal.
    ///
    /// # Arguments
    ///
    /// * `other` - The fragment to compare with
    ///
    /// # Returns
    ///
    /// `true` if the fragments have the same length and elements, `false` otherwise
    fn eq(self, other: Fragment<T, MaxLen>) -> bool {
        let res = &mut true;
        if self.length != other.length {
            *res = false;
        } else {
            self.each(|el, i| { *res &= el == other.at(i); });
        };

        *res
    }
}

mod tests {
    use super::Fragment;

    #[test]
    fn test_fragment_creation() {
        let data = [1, 2, 3, 4, 5];
        let fragment = Fragment::from_array(data);
        assert(fragment.len() == 5);
        assert(fragment.end() == 5);
    }

    #[test]
    fn test_fragment_from_array_with_len() {
        let data = [1, 2, 3, 4, 5];
        let fragment = Fragment::from_array_with_len(3, data);
        assert(fragment.len() == 3);
        assert(fragment.end() == 3);
    }

    #[test]
    fn test_fragment_sub_fragment() {
        let data = [1, 2, 3, 4, 5];
        let fragment = Fragment::from_array(data);
        let sub = fragment.sub_fragment(1, 3);
        assert(sub.len() == 3);
        assert(sub.end() == 4);
    }

    #[test]
    fn test_fragment_slice() {
        let data = [1, 2, 3, 4, 5];
        let fragment = Fragment::from_array(data);
        let slice = fragment.slice(1, 4);
        assert(slice.len() == 3);
        assert(slice.end() == 4);
    }

    #[test]
    fn test_fragment_focus() {
        let data = [1, 2, 3, 4, 5];
        let fragment = Fragment::from_array(data);
        let focused: Fragment<u8, 10> = fragment.focus();
        assert(focused.len() == 5);
        assert(focused.end() == 5);
    }

    #[test]
    fn test_fragment_push_pop() {
        let mut fragment: Fragment<u8, 10> = Fragment::empty();
        fragment = fragment.push_back(1);
        fragment = fragment.push_back(2);
        fragment = fragment.push_back(3);
        assert(fragment.len() == 3);
        assert(fragment.pop_back() == 3);
        assert(fragment.len() == 2);
        assert(fragment.pop_front() == 1);
        assert(fragment.len() == 1);
    }

    #[test]
    fn test_fragment_first_last() {
        let data = [1, 2, 3, 4, 5];
        let fragment = Fragment::from_array(data);
        assert(fragment.first() == 1);
        assert(fragment.last() == 5);
    }

    #[test]
    fn test_fragment_extend() {
        let mut fragment: Fragment<u8, 10> = Fragment::empty();
        fragment = fragment.extend_from_array([1, 2, 3]);
        assert(fragment.len() == 3);
        fragment = fragment.extend_from_array([4, 5]);
        assert(fragment.len() == 5);
    }

    #[test]
    fn test_fragment_equality() {
        let data1 = [1, 2, 3, 4, 5];
        let data2 = [1, 2, 3, 4, 5];
        let fragment1 = Fragment::from_array(data1);
        let fragment2 = Fragment::from_array(data2);
        assert(fragment1 == fragment2);
    }

    #[test]
    fn test_fragment_validity() {
        let data = [1, 2, 3, 4, 5];
        let fragment = Fragment::from_array(data);
        assert(fragment.is_valid());
        assert(fragment.is_within_bounds(5));
        assert(!fragment.is_within_bounds(4));
    }

    #[test]
    fn test_fragment_empty() {
        let fragment: Fragment<u8, 10> = Fragment::empty();
        assert(fragment.is_empty());
        assert(fragment.len() == 0);
        assert(fragment.is_valid());
    }

}

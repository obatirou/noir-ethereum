use crate::helpers::if_else;
use std::mem::zeroed;

pub struct Fragment<T, let MaxLen: u32> {
    offset: u64,
    length: u64,
    data: [T; MaxLen],
}

impl<T, let MaxLen: u32> Fragment<T, MaxLen> {
    pub fn new(offset: u64, length: u64, data: [T; MaxLen]) -> Self {
        assert(
            offset + length <= data.len() as u64,
            "Offset and length exceed the length of the data",
        );
        Self { offset, length, data }
    }

    pub fn from_array(data: [T; MaxLen]) -> Self {
        Self::new(0, data.len() as u64, data)
    }

    pub fn from_bounded_vec(vec: BoundedVec<T, MaxLen>) -> Self {
        Self::new(0, MaxLen as u64, vec.storage())
    }

    pub fn extend_from_array<let N: u32>(mut self, array: [T; N]) -> Self {
        let new_length = self.length + array.len() as u64;
        assert(new_length <= MaxLen as u64, "Extended length exceeds maximum fragment length");

        for i in 0..N {
            self.data[self.end() as u32 + i] = array[i];
        }
        self.length = new_length;
        self
    }

    pub fn extend_from_bounded_vec<let N: u32>(mut self, vec: BoundedVec<T, N>) -> Self {
        let new_length = self.length + vec.len() as u64;
        assert(new_length <= MaxLen as u64, "Extended length exceeds maximum fragment length");

        for i in 0..vec.len() {
            self.data[self.end() as u32 + i] = vec.get(i);
        }
        self.length = new_length;
        self
    }

    pub fn len(self) -> u64 {
        self.length
    }

    pub fn empty() -> Self {
        Self { offset: 0, length: 0, data: zeroed() }
    }

    pub fn is_empty(self) -> bool {
        self.length == 0
    }

    pub fn pop_front(mut self) -> T {
        assert(self.length > 0, "Fragment is empty");
        self.offset += 1;
        self.length -= 1;
        self.data[self.offset - 1]
    }

    pub fn at(self, index: u64) -> T {
        assert(index < self.length, "Index out of bounds");
        self.data[self.offset + index]
    }

    pub fn sub_fragment(self, offset: u64, length: u64) -> Fragment<T, MaxLen> {
        assert(offset + length <= self.length, "Offset and length exceed the length of the data");
        Fragment { offset: self.offset + offset, length, data: self.data }
    }

    pub fn end(self) -> u64 {
        self.offset + self.length
    }

    pub fn is_valid(self) -> bool {
        let valid_length = self.length >= 0;
        let within_bounds = self.end() <= self.data.len() as u64;
        valid_length & within_bounds
    }

    pub fn is_within_bounds(self, max_length: u64) -> bool {
        self.end() <= max_length
    }

    pub fn is_contiguous(self, other: Self) -> bool {
        self.end() == other.offset
    }

    pub fn overlaps(self, other: Self) -> bool {
        let self_end = self.end();
        let other_end = other.end();
        ((self.offset <= other.offset) & (self_end > other.offset))
            | ((other.offset <= self.offset) & (other_end > self.offset))
    }

    pub fn contains(self, other: Self) -> bool {
        let self_end = self.end();
        let other_end = other.end();
        (self.offset <= other.offset) & (self_end >= other_end)
    }

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
        Self::new(new_offset, new_length, self.data)
    }

    pub fn slice(self, start: u64, end: u64) -> Self {
        assert(start <= end, "Start must be less than or equal to end");
        assert(end <= self.length, "End must be less than or equal to length");
        Self::new(self.offset + start, end - start, self.data)
    }

    pub fn first(self) -> T {
        assert(!self.is_empty(), "Fragment is empty");
        self.data[self.offset]
    }

    pub fn last(self) -> T {
        assert(!self.is_empty(), "Fragment is empty");
        self.data[self.end() - 1]
    }

    pub fn push_back(mut self, value: T) -> Self {
        assert(self.end() < self.data.len() as u64, "Fragment is full");
        self.data[self.end()] = value;
        self.length += 1;
        self
    }

    pub fn pop_back(mut self) -> T {
        assert(!self.is_empty(), "Fragment is empty");
        self.length -= 1;
        self.data[self.end()]
    }
}

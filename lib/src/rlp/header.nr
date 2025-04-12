use crate::helpers::if_else;
use super::constants::{List, String};

pub struct RlpHeader {
    offset: u64,
    length: u64,
    data_type: u8,
}

impl RlpHeader {
    pub fn new(offset: u64, length: u64, data_type: u8) -> Self {
        Self { offset, length, data_type }
    }

    pub fn is_string(self) -> bool {
        self.data_type == String
    }

    pub fn is_list(self) -> bool {
        self.data_type == List
    }

    pub fn is_empty(self) -> bool {
        self.length == 0
    }

    pub fn len(self) -> u64 {
        self.length
    }

    pub fn offset(self) -> u64 {
        self.offset
    }

    pub fn data_type(self) -> u8 {
        self.data_type
    }

    pub fn end(self) -> u64 {
        self.offset + self.length
    }

    pub fn is_valid(self) -> bool {
        let valid_type = (self.data_type == String) | (self.data_type == List);
        let valid_length = self.length >= 0;
        valid_type & valid_length
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
        Self::new(new_offset, new_length, self.data_type)
    }
}

impl Eq for RlpHeader {
    fn eq(self, other: Self) -> bool {
        (self.offset == other.offset)
            & (self.length == other.length)
            & (self.data_type == other.data_type)
    }
}

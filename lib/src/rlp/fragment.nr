use super::constants::{List, String};
use super::header::RlpHeader;

pub struct RlpFragment {
    offset: u64,
    length: u64,
    data_type: u8,
}

impl RlpFragment {
    pub fn new(offset: u64, length: u64, data_type: u8) -> Self {
        Self { offset, length, data_type }
    }

    pub fn from_header(header: RlpHeader) -> Self {
        Self::new(header.offset(), header.len(), header.data_type())
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

    pub fn contains(self, other: Self) -> bool {
        let self_end = self.end();
        let other_end = other.end();
        (self.offset <= other.offset) * (self_end >= other_end)
    }

    pub fn overlaps(self, other: Self) -> bool {
        let self_end = self.end();
        let other_end = other.end();
        ((self.offset <= other.offset) * (self_end > other.offset))
            + ((other.offset <= self.offset) * (other_end > self.offset))
    }

    pub fn is_valid(self) -> bool {
        (self.length > 0) + self.is_empty()
    }
}

impl Eq for RlpFragment {
    fn eq(self, other: Self) -> bool {
        (self.offset == other.offset)
            & (self.length == other.length)
            & (self.data_type == other.data_type)
    }
}

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
}

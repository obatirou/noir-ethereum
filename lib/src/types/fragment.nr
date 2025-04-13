use crate::helpers::arrays::memcpy_up_to_length;
use crate::helpers::iterator::Iterator;
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

    pub fn from_vec(vec: BoundedVec<T, MaxLen>) -> Self {
        Fragment { offset: 0, length: vec.len().into(), data: vec.storage() }
    }

    pub fn from_array_with_len(length: u64, data: [T; MaxLen]) -> Self {
        assert(length <= data.len() as u64, "Fragment length exceeds data length");

        Fragment { offset: 0, length, data }
    }

    pub fn extend_from_array<let N: u32>(&mut self, array: [T; N]) -> Self {
        let new_length = self.length + array.len() as u64;
        assert(new_length <= MaxLen as u64, "Extended length exceeds maximum fragment length");

        for i in 0..N {
            self.data[self.end() as u32 + i] = array[i];
        }
        self.length = new_length;
        *self
    }

    pub fn extend_from_bounded_vec<let N: u32>(&mut self, vec: BoundedVec<T, N>) -> Self {
        let new_length = self.length + vec.len() as u64;
        assert(new_length <= MaxLen as u64, "Extended length exceeds maximum fragment length");

        for i in 0..vec.len() {
            self.data[self.end() as u32 + i] = vec.get(i);
        }
        self.length = new_length;
        *self
    }

    pub fn len(self) -> u64 {
        self.length
    }

    pub fn data(self) -> [T; MaxLen] {
        self.data
    }

    pub fn empty() -> Self {
        Self { offset: 0, length: 0, data: zeroed() }
    }

    pub fn is_empty(self) -> bool {
        self.length == 0
    }

    pub fn pop_front(&mut self) -> T {
        assert(self.length > 0, "Fragment is empty");
        self.offset += 1;
        self.length -= 1;
        self.data[self.offset - 1]
    }

    pub fn at(self, index: u64) -> T {
        assert(index < self.length, "Index out of bounds");
        self.data[self.offset + index]
    }

    pub fn set(&mut self, index: u64, value: T) {
        let length = self.length;
        assert(
            index < self.length,
            f"Index out of bounds, tried to set at index {index} but the length is {length}",
        );

        self.data[self.offset + index] = value;
    }

    pub fn sub_fragment(self, offset: u64, length: u64) -> Fragment<T, MaxLen> {
        assert(offset + length <= self.length, "Offset and length exceed the length of the data");
        Fragment { offset: self.offset + offset, length, data: self.data }
    }

    pub fn focus<let NewMaxLen: u32>(self) -> Fragment<T, NewMaxLen> {
        assert((NewMaxLen as u64) >= self.length, "New max length is smaller than fragment length");

        let mut new_data: [T; NewMaxLen] = zeroed();
        memcpy_up_to_length(&mut new_data, self.data, self.offset, self.length);

        Fragment { offset: 0, length: self.length, data: new_data }
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

    pub fn push_back(&mut self, value: T) -> Self {
        assert(self.end() < self.data.len() as u64, "Fragment is full");
        self.data[self.end()] = value;
        self.length += 1;
        *self
    }

    pub fn pop_back(&mut self) -> T {
        assert(!self.is_empty(), "Fragment is empty");
        self.length -= 1;
        self.data[self.end()]
    }

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

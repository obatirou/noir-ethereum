global String: u8 = 0;
global List: u8 = 1;

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
}

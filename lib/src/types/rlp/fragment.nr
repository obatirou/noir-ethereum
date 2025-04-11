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
}

use super::constants::MAX_HEADER_SIZE;

pub type BlockHeaderRlp = BoundedVec<u8, MAX_HEADER_SIZE>;

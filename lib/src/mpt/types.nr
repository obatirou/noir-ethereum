use super::constants::MAX_NODE_LEN;

pub type Node = [u8; MAX_NODE_LEN];
pub type Leaf<let MaxLeafLen: u32> = [u8; MaxLeafLen];
pub type Key<let MaxKeyLen: u32> = [u8; MaxKeyLen];
pub type Value<let MaxValueLen: u32> = [u8; MaxValueLen];

use crate::mpt::proof::{Proof, ProofInput};

use crate::mpt::types::{Key, Value};
use crate::mpt::types::Leaf;
use crate::types::hash::Hash;

pub global root: Hash = [
    0x47, 0x87, 0x4a, 0xfc, 0xf1, 0x15, 0x5a, 0x5d, 0x85, 0xbd, 0x33, 0x30, 0x92, 0xf4, 0xb9, 0x9a,
    0xbe, 0xf4, 0xc5, 0xfc, 0xdc, 0x5c, 0x68, 0xd, 0x71, 0xf5, 0xa3, 0xab, 0x11, 0xe0, 0x60, 0x11,
];

pub global key: Key<20> = [
    0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x74, 0x65, 0x73, 0x74, 0x5f, 0x6b,
    0x65, 0x79,
];
pub global value: Value<10> = [0x74, 0x65, 0x73, 0x74, 0x5f, 0x76, 0x61, 0x6c, 0x75, 0x65];
pub global leaf: Leaf<22> = [
    0xd5, 0x89, 0x20, 0x74, 0x65, 0x73, 0x74, 0x5f, 0x6b, 0x65, 0x79, 0x8a, 0x74, 0x65, 0x73, 0x74,
    0x5f, 0x76, 0x61, 0x6c, 0x75, 0x65,
];

global proof: Proof<0, 22> = Proof::new([], leaf, 1);
pub global proof_input: ProofInput<20, 10, 0, 22> = ProofInput::new(key, value, proof);

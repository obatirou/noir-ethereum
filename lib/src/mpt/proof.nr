use super::types::{Key, Leaf, Node, Value};

pub struct Proof<let MaxDepth: u32, let MaxLeafLen: u32> {
    nodes: [Node; MaxDepth],
    leaf: Leaf<MaxLeafLen>,
    depth: u64,
}

impl<let MaxDepth: u32, let MaxLeafLen: u32> Proof<MaxDepth, MaxLeafLen> {
    pub fn new(nodes: [Node; MaxDepth], leaf: Leaf<MaxLeafLen>, depth: u64) -> Self {
        Self { nodes, leaf, depth }
    }

    pub fn nodes(self) -> [Node; MaxDepth] {
        self.nodes
    }

    pub fn leaf(self) -> Leaf<MaxLeafLen> {
        self.leaf
    }

    pub fn depth(self) -> u64 {
        self.depth
    }
}

impl<let MaxDepth: u32, let MaxLeafLen: u32> Eq for Proof<MaxDepth, MaxLeafLen> {
    fn eq(self, other: Self) -> bool {
        (self.depth == other.depth) & (self.leaf == other.leaf) & (self.nodes == other.nodes)
    }
}

pub struct ProofInput<let MaxKeyLen: u32, let MaxValueLen: u32, let MaxDepth: u32, let MaxLeafLen: u32> {
    key: Key<MaxKeyLen>,
    value: Value<MaxValueLen>,
    proof: Proof<MaxDepth, MaxLeafLen>,
}

impl<let MaxKeyLen: u32, let MaxValueLen: u32, let MaxDepth: u32, let MaxLeafLen: u32> ProofInput<MaxKeyLen, MaxValueLen, MaxDepth, MaxLeafLen> {
    pub fn new(
        key: Key<MaxKeyLen>,
        value: Value<MaxValueLen>,
        proof: Proof<MaxDepth, MaxLeafLen>,
    ) -> Self {
        Self { key, value, proof }
    }

    pub fn key(self) -> Key<MaxKeyLen> {
        self.key
    }

    pub fn value(self) -> Value<MaxValueLen> {
        self.value
    }

    pub fn proof(self) -> Proof<MaxDepth, MaxLeafLen> {
        self.proof
    }
}

impl<let MaxKeyLen: u32, let MaxValueLen: u32, let MaxDepth: u32, let MaxLeafLen: u32> Eq for ProofInput<MaxKeyLen, MaxValueLen, MaxDepth, MaxLeafLen> {
    fn eq(self, other: Self) -> bool {
        (self.key == other.key) & (self.value == other.value) & (self.proof == other.proof)
    }
}

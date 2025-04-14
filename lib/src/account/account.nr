use crate::types::{address::Address, bytes32::Bytes32};

pub struct Account {
    address: Address,
    balance: Field,
    code_hash: Bytes32,
    nonce: u64,
    storage_hash: Bytes32,
}

impl Account {
    pub fn new(
        address: Address,
        nonce: u64,
        balance: Field,
        storage_hash: Bytes32,
        code_hash: Bytes32,
    ) -> Self {
        Self { address, nonce, balance, storage_hash, code_hash }
    }

    pub fn address(self) -> Address {
        self.address
    }

    pub fn nonce(self) -> u64 {
        self.nonce
    }

    pub fn balance(self) -> Field {
        self.balance
    }

    pub fn storage_hash(self) -> Bytes32 {
        self.storage_hash
    }

    pub fn code_hash(self) -> Bytes32 {
        self.code_hash
    }
}

impl Eq for Account {
    fn eq(self, other: Self) -> bool {
        (self.address == other.address)
            & (self.nonce == other.nonce)
            & (self.balance == other.balance)
            & (self.storage_hash == other.storage_hash)
            & (self.code_hash == other.code_hash)
    }
}

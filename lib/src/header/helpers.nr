use crate::chain::constants::{ETHEREUM_MAINNET_CHAIN_ID, ETHEREUM_SEPOLIA_CHAIN_ID};

use super::constants::{CANCUN_BLOCK_NUMBER, LONDON_BLOCK_NUMBER, SHANGHAI_BLOCK_NUMBER};

pub fn get_header_fields_count(chain_id: u64, block_number: u64) -> u64 {
    let mut fields_count = 15;
    if chain_id == ETHEREUM_MAINNET_CHAIN_ID {
        if block_number >= LONDON_BLOCK_NUMBER {
            fields_count += 1;
        }
        if block_number >= SHANGHAI_BLOCK_NUMBER {
            fields_count += 1;
        }
        if block_number >= CANCUN_BLOCK_NUMBER {
            fields_count += 3;
        }
    } else if chain_id == ETHEREUM_SEPOLIA_CHAIN_ID {
        fields_count = 20;
    } else {
        assert(false, "Unsupported chain ID");
    }
    fields_count
}

pub global BYZANTIUM_BLOCK_NUMBER: u32 = 4_370_000;

pub global RECEIPT_FIELDS_COUNT: u32 = 4;
pub global STATE_ROOT_INDEX: u32 = 0;
pub global STATUS_INDEX: u32 = 0;
pub global CUMULATIVE_GAS_USED_INDEX: u32 = 1;
pub global LOGS_BLOOM_INDEX: u32 = 2;
pub global LOGS_INDEX: u32 = 3;

pub global BLOOM_FILTER_LENGTH: u32 = 256;

pub global LOG_FIELDS_COUNT: u32 = 3;
pub global LOG_ADDRESS_INDEX: u32 = 0;
pub global LOG_TOPICS_INDEX: u32 = 1;
pub global LOG_DATA_INDEX: u32 = 2;

pub global MAX_KEY_LENGTH: u32 = 3;
pub global MAX_PREFIXED_KEY_NIBBLE_LEN: u32 = 8; // (MAX_KEY_LENGTH + 1) * 2

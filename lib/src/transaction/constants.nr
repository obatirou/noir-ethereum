use super::transaction::TransactionPartialFieldLayout;

pub global MAX_TRANSACTION_FIELDS_COUNT: u32 = 14;

pub global TRANSACTION_TYPE_FIELD_LAYOUT: [TransactionPartialFieldLayout; 5] = [
    TransactionPartialFieldLayout::new(9, 0, 2, 3, 4, 5, 6),
    TransactionPartialFieldLayout::new(11, 1, 3, 4, 5, 6, 8),
    TransactionPartialFieldLayout::new(12, 1, 4, 5, 6, 7, 9),
    TransactionPartialFieldLayout::new(14, 1, 4, 5, 6, 7, 11),
    TransactionPartialFieldLayout::new(13, 1, 4, 5, 6, 7, 10),
];

pub global MAX_ENCODED_TRANSACTION_LENGTH: u32 = 525;
pub global MAX_TRANSACTION_RLP_LENGTH: u32 = MAX_ENCODED_TRANSACTION_LENGTH - 1;
pub global MAX_KEY_LENGTH: u32 = 3;
pub global MAX_DEPTH_NO_LEAF: u32 = 6;
pub global MAX_PREFIXED_KEY_NIBBLE_LENGTH: u32 = 8; // (MAX_KEY_LENGTH + 1) * 2

use crate::transaction::{
    constants::MAX_PREFIXED_KEY_NIBBLE_LENGTH, transaction::TransactionPartial,
    types::TransactionProof,
};

use crate::mpt::{proof::{Proof, ProofInput}, types::{Key, Value}};
use crate::types::hash::Hash;

pub global transaction_index: u64 = 137;
pub global transaction_type: u8 = 0;

pub global transaction_root: Hash = [
    152, 152, 147, 144, 219, 86, 48, 149, 109, 34, 3, 117, 168, 84, 20, 62, 254, 139, 104, 177, 172,
    186, 61, 26, 239, 106, 35, 102, 139, 226, 143, 20,
];

pub global MAX_DATA_LENGTH: u32 = 0;
pub global MAX_LEAF_LENGTH: u32 = 128;

pub global transaction: TransactionPartial<MAX_DATA_LENGTH> = TransactionPartial::new(
    21,
    21000,
    Option::some([
        132, 232, 163, 243, 89, 168, 159, 59, 134, 115, 176, 26, 31, 52, 11, 125, 219, 15, 219, 93,
    ]),
    U128::from_integer(0x37df8877cc256000),
    BoundedVec::new(),
    37,
    [
        165, 243, 1, 211, 99, 75, 206, 41, 209, 49, 85, 196, 88, 5, 159, 240, 44, 56, 106, 174, 36,
        113, 84, 111, 81, 38, 217, 0, 28, 99, 186, 77,
    ],
    [
        43, 37, 169, 172, 81, 39, 184, 162, 236, 13, 153, 163, 7, 183, 114, 98, 178, 241, 44, 154,
        103, 113, 123, 143, 111, 49, 206, 124, 33, 234, 245, 107,
    ],
);

global key: Key<MAX_PREFIXED_KEY_NIBBLE_LENGTH> = [0, 0, 0, 0, 0, 0, 129, 137];

global value: Value<525> = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    248, 107, 21, 132, 136, 173, 34, 12, 130, 82, 8, 148, 132, 232, 163, 243, 89, 168, 159, 59, 134,
    115, 176, 26, 31, 52, 11, 125, 219, 15, 219, 93, 136, 55, 223, 136, 119, 204, 37, 96, 0, 128,
    37, 160, 165, 243, 1, 211, 99, 75, 206, 41, 209, 49, 85, 196, 88, 5, 159, 240, 44, 56, 106, 174,
    36, 113, 84, 111, 81, 38, 217, 0, 28, 99, 186, 77, 160, 43, 37, 169, 172, 81, 39, 184, 162, 236,
    13, 153, 163, 7, 183, 114, 98, 178, 241, 44, 154, 103, 113, 123, 143, 111, 49, 206, 124, 33,
    234, 245, 107,
];

global proof: Proof<4, 128> = Proof::new(
    [
        [
            249, 1, 49, 160, 244, 108, 24, 171, 118, 66, 115, 23, 36, 9, 59, 6, 90, 170, 202, 47,
            50, 72, 225, 30, 181, 5, 215, 74, 236, 35, 190, 253, 129, 70, 55, 133, 160, 181, 60,
            133, 245, 191, 178, 245, 202, 133, 255, 176, 215, 98, 63, 31, 32, 35, 70, 178, 132, 58,
            53, 160, 45, 126, 7, 140, 117, 243, 12, 53, 145, 160, 179, 224, 182, 124, 83, 14, 160,
            91, 246, 91, 242, 135, 254, 81, 192, 62, 10, 143, 91, 223, 121, 88, 177, 25, 51, 122,
            45, 58, 166, 2, 169, 9, 160, 171, 0, 182, 157, 184, 55, 153, 41, 3, 0, 217, 49, 180, 78,
            81, 79, 109, 212, 147, 169, 153, 197, 220, 109, 206, 70, 159, 215, 59, 112, 67, 170,
            160, 225, 6, 104, 102, 201, 254, 140, 23, 89, 150, 66, 118, 154, 24, 255, 224, 178, 132,
            84, 108, 243, 228, 70, 158, 70, 200, 234, 10, 174, 102, 223, 59, 160, 64, 218, 247, 25,
            133, 117, 123, 78, 243, 114, 44, 195, 30, 20, 240, 181, 244, 124, 19, 118, 18, 122, 80,
            63, 64, 91, 231, 116, 28, 119, 123, 222, 160, 16, 155, 236, 36, 55, 100, 0, 27, 67, 37,
            252, 114, 165, 167, 230, 208, 81, 247, 149, 104, 141, 178, 165, 241, 136, 57, 64, 168,
            148, 219, 253, 237, 160, 144, 86, 222, 236, 154, 120, 24, 109, 126, 75, 152, 208, 109,
            252, 190, 107, 29, 10, 30, 232, 82, 240, 171, 153, 220, 153, 49, 40, 225, 117, 73, 210,
            160, 231, 30, 100, 11, 247, 26, 134, 112, 51, 110, 1, 56, 55, 166, 62, 216, 108, 253,
            112, 128, 195, 35, 147, 243, 92, 135, 84, 230, 152, 123, 88, 233, 128, 128, 128, 128,
            128, 128, 128, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ],
        [
            248, 81, 160, 3, 88, 57, 42, 46, 191, 234, 217, 233, 209, 149, 210, 59, 159, 233, 60,
            39, 57, 127, 38, 6, 75, 135, 64, 255, 191, 60, 225, 221, 228, 123, 194, 160, 46, 94,
            125, 73, 184, 18, 39, 30, 167, 8, 192, 237, 156, 126, 84, 51, 238, 29, 108, 218, 47,
            185, 119, 231, 150, 153, 241, 216, 2, 174, 169, 163, 128, 128, 128, 128, 128, 128, 128,
            128, 128, 128, 128, 128, 128, 128, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ],
        [
            248, 113, 128, 128, 128, 128, 128, 128, 128, 128, 160, 11, 60, 242, 160, 194, 65, 207,
            187, 6, 230, 61, 229, 216, 194, 173, 170, 213, 182, 141, 90, 242, 44, 48, 87, 102, 22,
            129, 56, 182, 241, 15, 168, 160, 41, 120, 123, 188, 147, 69, 179, 61, 155, 207, 115,
            140, 44, 132, 108, 6, 243, 55, 8, 225, 189, 15, 92, 181, 2, 237, 252, 22, 200, 214, 215,
            104, 160, 6, 49, 53, 15, 9, 21, 221, 61, 229, 96, 59, 94, 92, 145, 107, 31, 214, 79,
            188, 42, 69, 109, 211, 143, 26, 28, 181, 151, 231, 191, 105, 189, 128, 128, 128, 128,
            128, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ],
        [
            249, 2, 17, 160, 176, 160, 146, 39, 54, 121, 141, 72, 172, 253, 212, 150, 65, 242, 35,
            190, 37, 100, 224, 56, 216, 164, 127, 131, 102, 169, 7, 211, 206, 106, 104, 86, 160, 77,
            11, 188, 45, 162, 74, 147, 156, 216, 207, 203, 223, 184, 223, 179, 24, 53, 138, 212,
            114, 137, 233, 109, 86, 86, 189, 72, 39, 97, 158, 215, 221, 160, 171, 192, 175, 100,
            249, 35, 183, 131, 125, 170, 124, 188, 196, 231, 202, 189, 129, 31, 19, 233, 151, 88,
            60, 238, 60, 109, 95, 55, 84, 49, 173, 181, 160, 185, 130, 219, 132, 253, 230, 24, 21,
            131, 21, 235, 127, 201, 177, 40, 54, 135, 149, 136, 228, 175, 133, 20, 201, 84, 115,
            126, 183, 81, 215, 42, 48, 160, 120, 179, 31, 194, 233, 34, 223, 223, 65, 23, 92, 104,
            55, 216, 201, 151, 205, 164, 113, 173, 129, 57, 83, 196, 109, 50, 178, 202, 220, 0, 170,
            113, 160, 251, 184, 245, 2, 155, 200, 174, 83, 219, 126, 245, 247, 115, 153, 168, 51,
            90, 187, 4, 100, 234, 95, 210, 209, 163, 184, 236, 64, 50, 244, 37, 228, 160, 22, 18,
            250, 208, 49, 28, 161, 193, 135, 61, 226, 37, 149, 105, 248, 189, 30, 23, 48, 241, 151,
            158, 144, 80, 180, 157, 110, 117, 11, 51, 177, 50, 160, 230, 39, 83, 97, 253, 182, 154,
            158, 228, 21, 75, 46, 58, 18, 134, 0, 167, 107, 116, 105, 84, 224, 177, 203, 74, 168,
            186, 103, 122, 223, 143, 107, 160, 28, 186, 25, 62, 207, 147, 195, 226, 135, 36, 105,
            115, 244, 161, 236, 69, 210, 62, 28, 207, 123, 57, 171, 152, 255, 98, 178, 204, 135,
            178, 246, 8, 160, 60, 214, 218, 194, 94, 173, 253, 177, 215, 198, 199, 236, 97, 10, 154,
            212, 187, 250, 100, 22, 141, 218, 182, 79, 207, 249, 206, 56, 28, 8, 197, 233, 160, 132,
            90, 243, 217, 230, 131, 202, 84, 154, 95, 56, 25, 247, 238, 178, 128, 10, 25, 105, 121,
            253, 9, 86, 146, 114, 25, 181, 102, 251, 202, 23, 124, 160, 161, 81, 123, 39, 91, 244,
            18, 75, 231, 88, 163, 14, 14, 197, 113, 187, 210, 121, 204, 164, 3, 216, 253, 135, 224,
            47, 243, 77, 26, 53, 84, 0, 160, 50, 94, 157, 136, 247, 180, 85, 150, 55, 73, 157, 104,
            114, 251, 25, 138, 160, 2, 36, 10, 194, 142, 221, 41, 237, 150, 168, 119, 116, 248, 140,
            159, 160, 182, 175, 51, 233, 25, 136, 239, 202, 58, 91, 61, 191, 127, 39, 45, 255, 172,
            98, 2, 180, 26, 169, 160, 74, 100, 65, 160, 32, 185, 20, 151, 112, 160, 141, 76, 215,
            123, 152, 118, 207, 232, 181, 149, 80, 185, 37, 229, 109, 11, 208, 82, 174, 3, 200, 43,
            130, 233, 86, 64, 61, 156, 50, 221, 136, 47, 160, 51, 26, 58, 121, 152, 254, 128, 193,
            36, 157, 221, 202, 242, 245, 117, 138, 160, 235, 183, 169, 254, 77, 129, 186, 253, 118,
            75, 127, 95, 211, 250, 21, 128,
        ],
    ],
    [
        248, 112, 32, 184, 109, 248, 107, 21, 132, 136, 173, 34, 12, 130, 82, 8, 148, 132, 232, 163,
        243, 89, 168, 159, 59, 134, 115, 176, 26, 31, 52, 11, 125, 219, 15, 219, 93, 136, 55, 223,
        136, 119, 204, 37, 96, 0, 128, 37, 160, 165, 243, 1, 211, 99, 75, 206, 41, 209, 49, 85, 196,
        88, 5, 159, 240, 44, 56, 106, 174, 36, 113, 84, 111, 81, 38, 217, 0, 28, 99, 186, 77, 160,
        43, 37, 169, 172, 81, 39, 184, 162, 236, 13, 153, 163, 7, 183, 114, 98, 178, 241, 44, 154,
        103, 113, 123, 143, 111, 49, 206, 124, 33, 234, 245, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0,
    ],
    5,
);

pub global transaction_proof: TransactionProof<MAX_LEAF_LENGTH, 525, 4> =
    ProofInput::new(key, value, proof);

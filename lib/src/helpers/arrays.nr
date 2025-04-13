/// Array helper functions for memory operations and array comparisons.
/// These functions provide safe and efficient ways to work with fixed-size arrays in Noir.

/// Copies elements from a source array to a destination array up to a specified length.
///
/// # Arguments
///
/// * `dest` - Mutable reference to the destination array
/// * `src` - Source array to copy from
/// * `offset` - Starting index in the source array
/// * `length` - Number of elements to copy
///
/// # Panics
///
/// * If length exceeds destination array size
/// * If offset + length exceeds source array size
pub fn memcpy_up_to_length<T, let SourceLen: u32, let DestLen: u32>(
    dest: &mut [T; DestLen],
    src: [T; SourceLen],
    offset: u64,
    length: u64,
) {
    assert(length <= DestLen.into(), "Destination index out of bound");
    assert(offset + length <= SourceLen.into(), "Source index out of bound");
    for i in 0..(DestLen as u64) {
        if i < length {
            (*dest)[i] = src[offset + i];
        }
    }
}

/// Copies elements from a source array to a destination array.
/// This is a convenience wrapper around memcpy_up_to_length that copies the entire destination array.
///
/// # Arguments
///
/// * `dest` - Mutable reference to the destination array
/// * `src` - Source array to copy from
/// * `offset` - Starting index in the source array
///
/// # Panics
///
/// * If source array is smaller than destination array
/// * If offset + destination length exceeds source array size
pub fn memcpy<T, let SourceLen: u32, let DestLen: u32>(
    dest: &mut [T; DestLen],
    src: [T; SourceLen],
    offset: u64,
) {
    memcpy_up_to_length(dest, src, offset, DestLen.into());
}

/// Compares a subarray with a portion of a larger array for equality.
///
/// # Arguments
///
/// * `subarray` - The subarray to compare
/// * `array` - The larger array to compare against
/// * `offset` - Starting index in the larger array
/// * `length` - Number of elements to compare
///
/// # Returns
///
/// * `true` if the subarray matches the portion of the larger array
/// * `false` otherwise
///
/// # Panics
///
/// * If length exceeds subarray size
/// * If offset + length exceeds array size
pub fn sub_array_equals_up_to_length<T, let SubArrayLen: u32, let ArrayLen: u32>(
    subarray: [T; SubArrayLen],
    array: [T; ArrayLen],
    offset: u64,
    length: u64,
) -> bool
where
    T: Eq,
{
    assert(length <= SubArrayLen.into(), "Subarray index out of bound");
    assert(offset + length <= ArrayLen.into(), "Array index out of bound");
    let mut result = true;
    for i in 0..SubArrayLen {
        if i.into() < length {
            result &= subarray[i] == array[offset + i as u64];
        }
    }
    result
}

mod tests {
    use super::{memcpy, memcpy_up_to_length, sub_array_equals_up_to_length};

    #[test]
    fn test_memcpy_up_to_length_basic() {
        let src = [1, 2, 3, 4, 5];
        let mut dest = [0; 3];
        memcpy_up_to_length(&mut dest, src, 1, 3);
        assert(dest == [2, 3, 4], "Basic memcpy failed");
    }

    #[test]
    fn test_memcpy_up_to_length_partial() {
        let src = [1, 2, 3, 4, 5];
        let mut dest = [0; 5];
        memcpy_up_to_length(&mut dest, src, 0, 3);
        assert(dest == [1, 2, 3, 0, 0], "Partial memcpy failed");
    }

    #[test(should_fail_with = "Destination index out of bound")]
    fn test_memcpy_up_to_length_dest_bound() {
        let src = [1, 2, 3];
        let mut dest = [0; 2];
        memcpy_up_to_length(&mut dest, src, 0, 3);
    }

    #[test(should_fail_with = "Source index out of bound")]
    fn test_memcpy_up_to_length_src_bound() {
        let src = [1, 2, 3];
        let mut dest = [0; 3];
        memcpy_up_to_length(&mut dest, src, 1, 3);
    }

    #[test]
    fn test_memcpy_basic() {
        let src = [1, 2, 3, 4, 5];
        let mut dest = [0; 3];
        memcpy(&mut dest, src, 1);
        assert(dest == [2, 3, 4], "Basic memcpy failed");
    }

    #[test(should_fail_with = "Source index out of bound")]
    fn test_memcpy_src_bound() {
        let src = [1, 2, 3];
        let mut dest = [0; 3];
        memcpy(&mut dest, src, 1);
    }

    #[test]
    fn test_sub_array_equals_basic() {
        let subarray = [2, 3, 4];
        let array = [1, 2, 3, 4, 5];
        assert(
            sub_array_equals_up_to_length(subarray, array, 1, 3),
            "Basic subarray comparison failed",
        );
    }

    #[test]
    fn test_sub_array_equals_partial() {
        let subarray = [2, 3, 0];
        let array = [1, 2, 3, 4, 5];
        assert(
            sub_array_equals_up_to_length(subarray, array, 1, 2),
            "Partial subarray comparison failed",
        );
    }

    #[test]
    fn test_sub_array_equals_no_match() {
        let subarray = [2, 3, 4];
        let array = [1, 2, 3, 5, 5];
        assert(
            !sub_array_equals_up_to_length(subarray, array, 1, 3),
            "Non-matching subarray comparison failed",
        );
    }

    #[test(should_fail_with = "Subarray index out of bound")]
    fn test_sub_array_equals_sub_bound() {
        let subarray = [2, 3];
        let array = [1, 2, 3, 4, 5];
        let _ = sub_array_equals_up_to_length(subarray, array, 1, 3);
    }

    #[test(should_fail_with = "Array index out of bound")]
    fn test_sub_array_equals_array_bound() {
        let subarray = [2, 3, 4];
        let array = [1, 2, 3];
        let _ = sub_array_equals_up_to_length(subarray, array, 1, 3);
    }
}

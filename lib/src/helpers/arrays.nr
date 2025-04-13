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

pub fn memcpy<T, let SourceLen: u32, let DestLen: u32>(
    dest: &mut [T; DestLen],
    src: [T; SourceLen],
    offset: u64,
) {
    memcpy_up_to_length(dest, src, offset, DestLen.into());
}

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

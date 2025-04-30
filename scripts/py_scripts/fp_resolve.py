#!/usr/bin/env python
import struct
import numpy as np

def float_to_hex(f):
    """Convert float to IEEE 754 hex (as integer)"""
    return hex(struct.unpack('<I', struct.pack('<f', f))[0])

def float_to_bf16(f):
    """Convert float to BF16 hex (truncated FP32)"""
    np_float32 = np.float32(f)
    np_uint32 = np.frombuffer(np_float32.tobytes(), dtype=np.uint32)[0]
    bf16_uint16 = (np_uint32 >> 16) & 0xFFFF
    return hex(bf16_uint16)

def float_to_fp16(f):
    """Convert float to IEEE 754 FP16 hex"""
    np_float16 = np.float16(f)
    np_uint16 = np.frombuffer(np_float16.tobytes(), dtype=np.uint16)[0]
    return hex(np_uint16)

def print_float_representations(f):
    print(f"Original Float (Decimal): {f}")
    print("-" * 50)
    
    # FP32
    fp32_hex = float_to_hex(f)
    fp32_int = int(fp32_hex, 16)
    print(f"FP32 (Float32):")
    print(f"  Hex: {fp32_hex}")
    print(f"  Decimal (of hex): {fp32_int}")
    print(f"  Binary: {bin(fp32_int)[2:].zfill(32)}")
    
    # BF16
    bf16_hex = float_to_bf16(f)
    bf16_int = int(bf16_hex, 16)
    print(f"\nBF16 (Brain Float16):")
    print(f"  Hex: {bf16_hex}")
    print(f"  Decimal (of hex): {bf16_int}")
    print(f"  Binary: {bin(bf16_int)[2:].zfill(16)}")
    
    # FP16
    fp16_hex = float_to_fp16(f)
    fp16_int = int(fp16_hex, 16)
    print(f"\nFP16 (Half Precision):")
    print(f"  Hex: {fp16_hex}")
    print(f"  Decimal (of hex): {fp16_int}")
    print(f"  Binary: {bin(fp16_int)[2:].zfill(16)}")

if __name__ == "__main__":
    while True:
        try:
            user_input = input("Enter a float (or 'q' to quit): ")
            if user_input.lower() == 'q':
                break
            f = float(user_input)
            print_float_representations(f)
            print("\n" + "=" * 50)
        except ValueError:
            print("Invalid input. Please enter a float or 'q'.")
        finally:
            print("\n")


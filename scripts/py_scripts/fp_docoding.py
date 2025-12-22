#!/usr/bin/env python3
import struct

def int_to_bin(value: int, bits: int) -> str:
    """Return binary string with fixed width."""
    return format(value, f'0{bits}b')

def decode_all(value: int):
    """Decode integer encoding as float32 / bfloat16 / float16 (scalar)."""

    print(f"\nInput Integer Encoding: {value} (0x{value:08X})")
    print("-" * 70)

    # ---------------- float32 ----------------
    try:
        f32 = struct.unpack('<f', struct.pack('<I', value & 0xFFFFFFFF))[0]
        print(f"float32 : {f32!r}")
        print(f"  Bits  : {int_to_bin(value & 0xFFFFFFFF, 32)}")
    except Exception as e:
        print(f"float32 : error ({e})")

    # ---------------- bfloat16 ----------------
    try:
        # bfloat16 uses top 16 bits of a float32 encoding
        bf16_bits = (value & 0xFFFF) << 16
        bf16_val = struct.unpack('<f', struct.pack('<I', bf16_bits))[0]
        print(f"\nbfloat16: {bf16_val!r}")
        print(f"  Bits  : {int_to_bin(bf16_bits >> 16, 16)}")
    except Exception as e:
        print(f"bfloat16: error ({e})")

    # ---------------- float16 ----------------
    try:
        f16_bits = value & 0xFFFF
        f16_bytes = struct.pack('<H', f16_bits)
        f16_val = struct.unpack('<e', f16_bytes)[0]   # '<e' = IEEE half-precision
        print(f"\nfloat16 : {f16_val!r}")
        print(f"  Bits  : {int_to_bin(f16_bits, 16)}")
    except Exception as e:
        print(f"float16 : error ({e})")

    print("-" * 70)


if __name__ == "__main__":
    print("=== Decode Integer Encoding as FP32 / BF16 / FP16 ===")
    print("Enter integer (decimal or hex like 0x3F800000), or 'q' to quit.\n")

    while True:
        try:
            s = input("Enter integer (or 'q'): ").strip()
            if s.lower() == 'q':
                print("Bye.")
                break

            # support prefix 0x input
            val = int(s, 0)
            decode_all(val)

        except ValueError:
            print("Invalid input. Please enter a valid integer or hex literal.")
        except KeyboardInterrupt:
            print("\nInterrupted.")
            break

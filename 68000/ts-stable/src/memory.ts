import { MEM_START, MEM_SIZE } from './constants';
import { putStr } from './io';
import { Ptr } from './types';

export const buffer = new ArrayBuffer(MEM_SIZE);
export const mem = new DataView(buffer);

export let asmPtr = MEM_START;

export const setAsmPtr = (value: Ptr): void => {
    asmPtr = value;
};

export const def8 = (value: number): Ptr => {
    const result = asmPtr;
    mem.setUint8(0, value);
    setAsmPtr(asmPtr + 1);
    return result;
};

export const def16 = (value: number): Ptr => {
    const result = asmPtr;
    mem.setUint16(0, value);
    setAsmPtr(asmPtr + 2);
    return result;
};

export const def32 = (value: number): Ptr => {
    const result = asmPtr;
    mem.setUint32(asmPtr, value);
    setAsmPtr(asmPtr + 4);
    return result;
};

export const defStr = (str: string): Ptr => {
    const result = asmPtr;
    const bytes = new TextEncoder().encode(str);
    const { length } = bytes;
    for (let i = 0; i < length; i++) {
        mem.setUint8(asmPtr, bytes[i]);
        setAsmPtr(asmPtr + 1);
    }
    return result;
};

export const defSpace = (size: number): Ptr => {
    const result = asmPtr;
    setAsmPtr(asmPtr + size);
    return result;
};

export const getb = (offset: number): number => mem.getInt8(offset);
export const setb = (offset: number, value: number): void => {
    mem.setInt8(offset, value);
};

export const tget = (offset: number): number => {
    try {
        return mem.getInt32(offset + 1);
    } catch (e) {
        putStr(`\n\nError: tried to fetch number at address ${offset + 1}\n`);
        throw e;
    }
};
export const tset = (offset: number, value: number): void => {
    try {
        return mem.setInt32(offset + 1, value);
    } catch (e) {
        putStr(`\n\nError: tried to store number ${value} at address ${offset + 1}\n`);
        throw e;
    }
};

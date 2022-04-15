import { CELL } from './constants';
import { state } from './globals';
import { tget, tset } from './memory';

export const getStackPrompt = (): string => {
    let s = '';
    for (let i = 0; i < 4; i++) {
        const n = tget(state.sp + (i - 3) * CELL);
        s += `${n.toString()} `;
    }
    return `${s}>`;
};

export const pop = (): number => {
    const val = tget(state.sp);
    state.sp -= CELL;
    return val;
};
export const push = (value: number): void => {
    state.sp += CELL;
    tset(state.sp, value);
};
export const peek = (): number => tget(state.sp);
export const poke = (value: number): void => tset(state.sp, value);
export const peek2 = (): number => tget(state.sp - CELL);
export const poke2 = (value: number): void => tset(state.sp - CELL, value);

export const rpop = (): number => {
    const val = tget(state.rp);
    state.rp -= CELL;
    return val;
};
export const rpush = (value: number): void => {
    state.rp += CELL;
    tset(state.rp, value);
};
export const rpeek = (): number => tget(state.rp);
export const rpoke = (value: number): void => tset(state.rp, value);

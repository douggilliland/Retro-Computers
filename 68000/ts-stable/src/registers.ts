import { CELL } from './constants';
import { tget, tset } from './memory';

let selectedReg = 0;

export const selectReg = (reg: number): void => {
    selectedReg = reg;
};
export const getReg = (): number => tget(selectedReg * CELL);
export const setReg = (value: number): void => tset(selectedReg * CELL, value);

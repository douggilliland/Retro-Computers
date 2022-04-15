import { NULL } from './constants';
import { escapeHTML } from './utils';

export let inputBuffer = '';
export let outputBuffer = '';
export let unbuffered = false;

export const setInputBuffer = (value: string): void => {
    inputBuffer = value;
};

export const appendInputBuffer = (value: string): void => {
    inputBuffer += value;
};

export const setOutputBuffer = (value: string): void => {
    outputBuffer = value;
};

export const getquery = (): boolean => inputBuffer.length > 0;

export const getch = (): number => {
    if (inputBuffer.length === 0) return NULL;
    const ch = inputBuffer[0];
    inputBuffer = inputBuffer.slice(1);
    return ch.codePointAt(0)!;
};

export const putch = (value: number): void => {
    outputBuffer += String.fromCodePoint(value);
};

export const putStr = (value: string): void => {
    outputBuffer += value;
};

export const setUnbuffered = (mode:boolean):void => {
    unbuffered = mode;
};

export const echo = (ch:number):void => {
    if (ch === 0) return;
    const char = String.fromCharCode(ch);
    putStr(escapeHTML(char));
};
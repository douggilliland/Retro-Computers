// prettier-ignore
import {
    CAPOS, CNINE, CCBRACE, CQUOTE, 
    CTICK, CZERO, FALSE, 
    TRUE, CELL, CCPAREN, CCBRACK, CDOT, CMINUS, CPLUS, CSLASH, CSTAR,
} from './constants';
import { state } from './globals';

import { echo, getch, getquery, putch, putStr, setUnbuffered } from './io';
import { getb, tget, tset } from './memory';
import { getReg, selectReg, setReg } from './registers';
import { rpeek, rpop, rpush, poke, peek, pop, push, peek2, poke2 } from './stacks';
import { formatFloat } from './utils';

let ex = '';

const ADD = (): void => {
    if (!state.incMode) {
        const y = pop();
        const x = peek();
        poke(x + y);
    } else {
        setReg(getReg() + 1);
    }
};

const AND = (): void => {
    const val = pop();
    poke(peek() & val);
};

const CALL = (): void => {
    rpush(state.ip);
    state.ip = tget(state.token * CELL);
    if (state.ip === 0) {
        state.ip = rpop();
        return;
    }
    state.token = getb(state.ip);
    state.ip--;
};

const DEF = (): void => {
    const defCode = getb(state.ip + 1);
    tset(defCode * CELL, state.ip + 2);
    while (state.token !== CCBRACE) {
        state.ip++;
        state.token = getb(state.ip);
    }
};

const DIV = (): void => {
    const y = pop();
    const x = peek();
    poke(x / y);
};

const DOT = (): void => {
    const val = pop();
    putStr(val.toString());
};

const DROP = (): void => {
    pop();
};

const DUP = (): void => {
    const val = peek();
    push(val);
};

const DIGIT = (): void => {
    let s = '';
    while (state.token >= CZERO && state.token <= CNINE) {
        s += String.fromCharCode(state.token);
        state.ip++;
        state.token = getb(state.ip);
    }
    const i = Number(s);
    push(i);
    state.ip--;
};

const EMIT = (): void => {
    putch(pop());
};

const ENDDEF = (): void => {
    state.ip = rpop();
};

const ENDLOOP = (): void => {
    if (pop() !== FALSE) {
        state.ip = rpeek();
    } else {
        rpop();
    }
};

const EQUAL = (): void => {
    if (peek() === peek2()) {
        poke(TRUE);
    } else {
        poke(FALSE);
    }
};

const EXTERNAL = (): void => {
    state.ip++;
    while (getb(state.ip) !== CTICK) {
        ex += String.fromCharCode(getb(state.ip));
        state.ip++;
    }
    console.log(ex);
};

const FETCH = (): void => {
    push(tget(getReg() * CELL));
};

const FLOAT = (): void => {
    state.ip++;
    state.token = getb(state.ip);
    if (state.token === CAPOS) {
        poke(peek());
    } else if (state.token === CZERO) {
        poke(peek());
    } else if (state.token === CDOT) {
        putStr(formatFloat(pop()));
    } else if (state.token === CPLUS) {
        const val = pop();
        poke(peek() + val);
    } else if (state.token === CMINUS) {
        const val = pop();
        poke(peek() - val);
    } else if (state.token === CSTAR) {
        const val = pop();
        poke(peek() * val);
    } else if (state.token === CSLASH) {
        const val = pop();
        poke(peek() / val);
    }
};

const GREATER = (): void => {
    if (peek() < peek2()) {
        poke(TRUE);
    } else {
        poke(FALSE);
    }
};

const IF = (): void => {
    if (pop() === FALSE) {
        state.ip++;
        state.token = getb(state.ip);
        while (state.token !== CCPAREN) {
            state.ip++;
            state.token = getb(state.ip);
        }
    }
};

const KEY = (): void | boolean => {
    try {
        setUnbuffered(true);
        if (!getquery()) return true;
        const ch = getch();
        setUnbuffered(false);
        echo(ch);
        push(ch);
    } catch (e) {
        putStr('\n\nError: failed to get a key\n');
        throw e;
    }
};

const LESS = (): void => {
    if (peek() > peek2()) {
        poke(TRUE);
    } else {
        poke(FALSE);
    }
};

const LOOP = (): void => {
    rpush(state.ip);
    if (peek() === FALSE) {
        state.ip++;
        state.token = getb(state.ip);
        while (state.token !== CCBRACK) {
            state.ip++;
            state.token = getb(state.ip);
        }
    }
};

const MOD = (): void => {
    const val = pop();
    poke(peek() % val);
};

const MUL = (): void => {
    const y = pop();
    const x = peek();
    poke(x * y);
};

const NEGATE = (): void => {
    poke(-peek());
};

const NOP = (): void => {};

const NOT = (): void => {
    poke(~peek());
};

const OR = (): void => {
    const val = pop();
    poke(peek() | val);
};

const OVER = (): void => {
    push(peek2());
};

const PRINT = (): void => {
    state.ip++;
    state.token = getb(state.ip);
    while (state.token !== CQUOTE) {
        putch(state.token);
        state.ip++;
        state.token = getb(state.ip);
    }
};

const REG = (): void => {
    state.incMode = true;
    selectReg(state.token);
};

const RSET = (): void => {
    setReg(pop());
};

const RGET = (): void => {
    push(getReg());
};

const SUB = (): void => {
    if (!state.incMode) {
        const y = pop();
        const x = peek();
        poke(x - y);
    } else {
        setReg(getReg() - 1);
    }
};

const STORE = (): void => {
    tset(getReg() * CELL, pop());
};

const SWAP = (): void => {
    const i = peek();
    poke(peek2());
    poke2(i);
};

// prettier-ignore
export const opcodes = [ 
    NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, 
    NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, 
    NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, 
    NOP, NOP, NOP, STORE, PRINT, DUP, SWAP, MOD, AND, FLOAT, 
    IF, NOP, MUL, ADD, EMIT, SUB, DOT, DIV, DIGIT, DIGIT, 
    DIGIT, DIGIT, DIGIT, DIGIT, DIGIT, DIGIT, DIGIT, DIGIT, RSET, RGET, 
    LESS, EQUAL, GREATER, FETCH, OVER, CALL, CALL, CALL, CALL, CALL, 
    CALL, CALL, CALL, CALL, CALL, CALL, CALL, CALL, CALL, CALL, 
    CALL, CALL, CALL, CALL, CALL, CALL, CALL, CALL, CALL, CALL, 
    CALL, LOOP, DROP, ENDLOOP, KEY, NEGATE, EXTERNAL, REG, REG, REG, 
    REG, REG, REG, REG, REG, REG, REG, REG, REG, REG, 
    REG, REG, REG, REG, REG, REG, REG, REG, REG, REG, 
    REG, REG, REG, DEF, OR, ENDDEF, NOT, 
];

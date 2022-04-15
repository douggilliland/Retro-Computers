import { START_PROG } from './constants';
import { State } from './types';

export const state: State = {
    run: true,
    here: START_PROG,
    oldHere: START_PROG,

    ip: 0,
    token: 0,
    incMode: false,

    sp: 0,
    rp: 0,
};

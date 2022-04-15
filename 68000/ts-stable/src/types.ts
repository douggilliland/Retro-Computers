export type Ptr = number;

export interface State {
    run: boolean;
    here: number;
    oldHere: number;

    ip: number;
    token: number;
    incMode: boolean;

    sp: number;
    rp: number;
}

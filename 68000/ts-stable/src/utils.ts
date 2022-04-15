export const asBool = (b: boolean): number => (b ? -1 : 0);

export const formatFloat = (value: number): string => {
    return value.toFixed(2).replace(/0*$/, '').replace(/\.$/, '.0');
};

export const escapeHTML = (text: string): string => {
    return text.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
};

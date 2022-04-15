import 'regenerator-runtime/runtime';
import { inputBuffer, outputBuffer, setOutputBuffer } from './io';
import { interpReset, interpret } from './interpreter';
import { getStackPrompt } from './stacks';
import { escapeHTML } from './utils';
import { initListeners, log, setPrompt } from './dom';

initListeners();

const loop = () => {
    setTimeout(loop);
    if (outputBuffer.length > 0) {
        log(outputBuffer);
        setOutputBuffer('');
    }
};
loop();

setOutputBuffer('');
log(
    `TS-STABLE <a href="https://github.com/jhlagado/ts-stable"
        target="_blank" 
        title="An implementation of Sandor Schneider's STABLE language in Typescript by John Hardy ">(?)</a>`,
);
interpReset();
setPrompt(getStackPrompt());

const loop2 = async () => {
    const oldPrompt = getStackPrompt();
    const oldInputBuffer = inputBuffer;
    if (await interpret()) {
        log(`${oldPrompt} ${escapeHTML(oldInputBuffer)}`);
        setPrompt(getStackPrompt());
    }
    setTimeout(loop2);
};
loop2();

import { appendInputBuffer, unbuffered } from './io';

const history: string[] = [];
let historyIndex = 0;

export const initListeners = (): void => {
    const inputSource = document.getElementById('input_source')!;
    inputSource.onblur = () => {
        setTimeout(() => inputSource.focus(), 5000); // to allow selecting text put this on a 5 second timer
    };

    inputSource.addEventListener('keyup', async (event: KeyboardEvent) => {
        event.preventDefault();
        const { key } = event;
        if (key === 'ArrowUp') {
            if (history.length > historyIndex) {
                (inputSource as any).value = history[historyIndex++];
            }
        } else if (key === 'ArrowDown') {
            if (historyIndex > 0) {
                (inputSource as any).value = history[--historyIndex];
            }
        } else if (key === 'Enter' || unbuffered) {
            const text = (inputSource as any).value;
            history.unshift(text);
            historyIndex = 0;
            (inputSource as any).value = '';
            appendInputBuffer(text);
        }
    });
};

export const setPrompt = (text: string): void => {
    const prompt = document.getElementById('prompt');
    prompt!.innerText = text;
};

export const log = (message: string): void => {
    const output = document.getElementById('output');
    output!.innerHTML += `<div class='log'><p>${message}</p></div>`;
    const screen = document.getElementById('screen');
    screen!.scrollTop = screen!.scrollHeight;
};

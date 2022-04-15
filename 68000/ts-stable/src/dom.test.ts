import { initListeners, setPrompt } from './dom';

beforeEach(() => {
    document.body.innerHTML = `
    <div id="prompt"></div>
    <div id="input_source"></div>`;
});
it('should be set the prompt', async () => {
    initListeners();
    setPrompt('hello');
    const prompt = document.getElementById('prompt');
    expect(prompt!.innerText).toBe('hello');
});

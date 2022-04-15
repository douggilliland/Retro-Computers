import { JSDOM } from 'jsdom'

const dom = new JSDOM()
global.document = dom.window.document;
// (global as any).window = dom.window;

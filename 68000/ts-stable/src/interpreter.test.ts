import { interpReset, interpret } from './interpreter';
import { outputBuffer, setInputBuffer } from './io';

it('should be mastch code test 1', async () => {
    interpReset();
    setInputBuffer('49a: 5b: 89c: 1[b+;75*1023&#b:c;%1+.9,a;5%0=(10,)a-;]b;c%.');
    await interpret();
    expect(outputBuffer).toBe(`6\t34\t58\t61\t50\t
8\t16\t21\t33\t21\t
46\t20\t44\t73\t15\t
13\t38\t30\t12\t1\t
60\t26\t37\t28\t65\t
17\t45\t49\t9\t2\t
36\t20\t70\t26\t55\t
30\t25\t89\t13\t35\t
8\t57\t88\t78\t19\t
20\t57\t27\t13\t1`);
});

it('should be mastch code test 2', async () => {
    interpReset();
    setInputBuffer('{X 1[a; "Line begin " . " Line end." 10, a-; ] } 3a: X');
    await interpret();
    expect(outputBuffer).toBe(`Line begin 3 Line end.
Line begin 2 Line end.
Line begin 1 Line end.
`);
});

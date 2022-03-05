bufHigh = [];

bufLow = [];
console.log('table to multiply by 50');
for (var i = 0; i <= 40 ; i++) {
    let num = 50*i*3;
    let low = (num & 0x1F);
    let high = (num >> 5);
    let numstr = ("00" + low.toString(16)).slice(-2)
    bufLow.push("    .byte $"+numstr);

    numstr = ("00" + high.toString(16)).slice(-2)
    bufHigh.push("    .byte $"+numstr);
}
console.log("\nmult_table_high:")
console.log(bufHigh.join("\n"));
console.log("\nmult_table_low:")
console.log(bufLow.join("\n"));
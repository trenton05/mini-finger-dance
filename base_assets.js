const fs = require('fs');

const files = fs.readdirSync('./base_assets/assets/bin/Data');
const meta = './base_assets/assets/bin/Data/Managed/Metadata/global-metadata.dat';
const search = 'https://api.hangzhou.yxjhtech.com/DancingPadServer';
const replace = 'https://api.weavixdev.com/finger-dance-server-0123';

const data = fs.readFileSync(meta);
console.log(`Searching ${data.length} for ${search}`);
for (let i = data.length - search.length; i >= 0; i--) {
    const str = data.slice(i, i + search.length).toString('utf8');
    if (str === search) {
        console.log(`Replacing server at ${i} with ${replace}`);
        data.write(replace, i);
    } 
}
fs.writeFileSync(meta, data);

let diff = 0;
function modify(line) {
    const splits = line.split('|');
    return splits.map((x, i) => {
        const parts = x.split('*');
        if (parts.length !== 2) return x;

        const next = splits[i + 1];
        if (!next) return x;

        const nextStart = Number(next.split('*')[0]);
        const start = Number(parts[0]);
        const length = Number(parts[1]);
        if (start + length + 5 <= nextStart) return x;

        const change = start + length + 5 - nextStart;
        if (isNaN(change)) console.warn(`${start} ${length} ${nextStart} NaN`);
        diff += change;
        return change >= length ? `${start}` : `${start}*${length - change}`;
    }).join('|');
}

const names = [
    'After my heart was torn',
    'Every Morning',
    'Icarus',
    'The Splinter',
    'In the Groove',
    'Ride It',
    'Super Sonic',
    'Moto',
    'Warp Speed',
    'The Splinter',
    'Eye of the Tornado',
    'I\'m Your Girl',
    'Shifter',
    'Super Sonic',
    'Party',
    'MAMA',
    'Gee',
    'Moonlight Dance',
    'City Lights',
    'Jump Up',
    'Push Ya Back Out',
    'Checkmate',
    'Shining Star',
    'Ice Cream',
    'Rocket',
    'Selected',
    'White Walkers',
    'On My Mind'
];

files.forEach(file => {
    const path = `./base_assets/assets/bin/Data/${file}`;
    if (fs.statSync(path).isDirectory() || fs.statSync(path).size >= 20 * 1024) return;

    const data = fs.readFileSync(path);
    if (data.slice(20, 30).toString('utf8') === '2019.4.8f1') {
        const nameSize = data.readUInt32LE(0x1000);
        const nameBuffer = Math.ceil(nameSize / 4) * 4;
        const name = data.slice(0x1004, 0x1004 + nameSize);
        console.log(`Modifying ${file} ${name.toString('utf8')}`);
        if (!names.some(x => name.toString('utf8').toLowerCase().includes(`${x.toLowerCase()}_`))) return;
        const dataSize = data.readUInt32LE(0x1004 + nameBuffer);
        const blob = data.slice(0x1004 + nameBuffer + 4, 0x1004 + nameBuffer + 4 + dataSize);

        diff = 0;
        const lines = blob.toString('utf8').split('\r\n');
        const ul = modify(lines[0]);
        const ur = modify(lines[1]);
        const dl = modify(lines[2]);
        const dr = modify(lines[3]);
        const c = modify(lines[4]);
        const rest = lines.slice(5);
        rest[rest.length - 2] = 'MAIN_1';
        rest[rest.length - 3] = String(Number(rest[rest.length - 3]) - diff);

        const result = [ul, ur, dl, dr, c, ...rest].join('\r\n');
        const resultBuffer = Buffer.from(result, 'utf8');
        const resultSize = Math.ceil(resultBuffer.length / 4) * 4;
        const newData = Buffer.alloc(0x1000 + 8 + nameBuffer + resultSize);
        data.slice(0, 0x1000).copy(newData, 0);
        newData.writeUInt32LE(0, 6);
        newData.writeUInt32BE(newData.length, 4);
        newData.writeUInt32LE(4 + nameBuffer + 4 + resultSize, 0x50);
        newData.writeUInt32LE(nameSize, 0x1000);
        name.copy(newData, 0x1004);
        newData.writeUInt32LE(resultBuffer.length, 0x1004 + nameBuffer);
        resultBuffer.copy(newData, 0x1004 + nameBuffer + 4);

        fs.writeFileSync(path, newData);
        console.log(`Modified ${file} ${name.toString('utf8')} with difference ${diff}`);
    }
});

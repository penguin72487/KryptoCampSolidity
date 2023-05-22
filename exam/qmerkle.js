const ethers = require('ethers');


const addresses = [
    '0xdab15510af1425ba57499C2284cf420001A24D00',
    '0xA2F7B4eA63be89464bE01FB074d981F5917f53ef',
    '0x4197b82771654C0cE9049925845a8F942b58ccD0',
    '0x1b9024CFB1409c13f3B2ee422e9c196442c699E1',
    '0xEa36d9a9d90b7aFA41404CeCa0c06F9d3A75A8fa',
    '0x5ea8023bB1cca8aF07bcA9edB8FCE8b8a84C8B3f',
    '0x4bCae98Ab9912694af894D82658517782203a1dE',
    '0x2834A1487A841930b8b5b3C5812FB526A0189339'
];

const hashedAddresses = addresses.map(a => ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(['address'], [a])));

let tree = hashedAddresses;
while (tree.length > 1) {
    tree = ethers.utils.chunkify(tree, 2).map(pair => ethers.utils.keccak256(pair.reduce((res, hash) => res + hash.slice(2), '0x')));
}

console.log('Merkle Root:', tree[0]);

let proof = [];
let path = addresses.indexOf('0xdab15510af1425ba57499C2284cf420001A24D00');
let pathBits = path.toString(2).padStart(Math.log2(addresses.length), '0');
let currentHash = hashedAddresses[path];

for (let i = pathBits.length - 1; i >= 0; i--) {
    let pairIndex = pathBits[i] === '0' ? path + 1 : path - 1;
    proof.push(hashedAddresses[pairIndex]);
    currentHash = ethers.utils.keccak256(currentHash + hashedAddresses[pairIndex].slice(2));
    path = Math.floor(path / 2);
    hashedAddresses = ethers.utils.chunkify(hashedAddresses, 2).map(pair => ethers.utils.keccak256(pair.reduce((res, hash) => res + hash.slice(2), '0x')));
}

console.log('Proof for address1:', proof);

const fs = require('fs');
// const MerkleTree = require('merkle-tree-js');
const { MerkleTree } = require("merkletreejs");
const keccak256 = require('keccak256');

// Read CSV file
const data = fs.readFileSync('addresses.csv', 'utf8');
const lines = data.split('\n');

// Extract addresses and amounts
const entries = lines.slice(1).map((line) => {
  const [address, amount] = line.split(',');
  return { address, amount };
});

// Hash entries
const hashedEntries = entries.map((entry) => {
  return keccak256(Buffer.from(`${entry.address}${entry.amount}`, 'utf8'));
});

// Create Merkle tree
const merkleTree = new MerkleTree(hashedEntries, keccak256);

// Get Merkle root
const merkleRoot = merkleTree.getRoot().toString('hex');

console.log('Merkle Root:', merkleRoot);
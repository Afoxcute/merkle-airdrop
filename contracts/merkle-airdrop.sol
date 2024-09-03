// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./ERC20.sol"; // Assuming you have an ERC20 token contract


contract MerkleAirdrop {
    address public owner;
    ERC20 public token;
    bytes32 public merkleRoot;

    mapping(address => bool) public claimed;

    event Claimed(address indexed claimant, uint256 amount);

    constructor(address _token, bytes32 _merkleRoot) {
        owner = msg.sender;
        token = ERC20(_token);
        merkleRoot = _merkleRoot;
    }

    function claim(bytes32[] calldata proof, uint256 amount) external {
        require(!claimed[msg.sender], "Already claimed");

        // Verify Merkle proof
        bytes32 node = keccak256(abi.encodePacked(msg.sender, amount));
       require(MerkleProof.verify(proof, node, merkleRoot), "Invalid proof");

        // Transfer tokens
        token.transfer(msg.sender, amount);

        claimed[msg.sender] = true;
        emit Claimed(msg.sender, amount);
    }

    function updateMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");
        token.transfer(owner, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}
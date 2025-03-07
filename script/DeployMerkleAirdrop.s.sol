// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BegalToken} from "../src/begalToken.sol";
import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract DeployMerkleAirdrop is Script{
    bytes32 s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 s_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns(MerkleAirdrop , BegalToken){
        vm.startBroadcast();

        BegalToken token = new BegalToken();
        MerkleAirdrop airdrop = new MerkleAirdrop( s_merkleRoot , IERC20(address(token)));
        token.mint(token.owner() , s_amountToTransfer);
        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();

        return (airdrop , token);

        
    }

    function run() external returns(MerkleAirdrop , BegalToken){
        return deployMerkleAirdrop();
    }
}
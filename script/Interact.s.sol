// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script{
        address public CLAIMING_ADDRESS=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint256 public CLAIMING_AMOUNT=25 * 1e18;
        bytes32 proof_one=bytes32(0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad);
        bytes32 proof_two=bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576);
        bytes32[] public PROOF=[proof_one , proof_two]; 
        bytes private SIGNATURE=hex"84ffd6c4bc87580f8ca8f5a6a8a6aa62ed3a9c447c15f3e3e4632ea329464c20749b4df81eb1a49da762a92db2c49a3827df86a9dfc4ea05b56566a914da09601b";

        // """CUSTOM ERROR"""
        error __ClaimAirdrop_InvalidSignatureLength();

        // FUNCTION TO CLAIM THE AIRDROP
        function claimAirdrop(address airdrop) public {
        vm.startBroadcast(); // Use the vm instance provided by forge-std/Script.sol
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, PROOF, v, r, s);
        vm.stopBroadcast(); // Use the vm instance provided by forge-std/Script.sol
    }

        function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
            if(!(sig.length == 65)) {
                revert __ClaimAirdrop_InvalidSignatureLength();
            }
            assembly {
                r := mload(add(sig, 32))
                s := mload(add(sig, 64))
                v := byte(0, mload(add(sig, 96)))
            }
            return (v, r, s);
        }

        function run() external{
            address mostRecentDeployed= DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
            claimAirdrop(mostRecentDeployed);
        }
}
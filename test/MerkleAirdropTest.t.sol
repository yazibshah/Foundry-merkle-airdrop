// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test , console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BegalToken} from "../src/begalToken.sol";
import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker,Test{
    using SafeERC20 for BegalToken;
    BegalToken public  token;
    MerkleAirdrop public airdrop;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 
    public AMOUNT_TO_CLAIM= 25 * 1e18;
    uint256 public AMOUNT_TO_SEND=AMOUNT_TO_CLAIM *4;
    bytes32[] public PROOF = [bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a),
            bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
];
    address user;
    uint256 userPrivateKey;


    function setUp() public {
        if(!isZkSyncChain()){
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop , token) = deployer.deployMerkleAirdrop();
        }else{
            token = new BegalToken();
            airdrop = new MerkleAirdrop( ROOT,token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.safeTransfer(address(airdrop) , AMOUNT_TO_SEND);
        }

        (user , userPrivateKey) = makeAddrAndKey("user");
    } 
    
    function testUsersCanClaim() public{
        console.log("user Address" , user);
        uint256 startingbalance = token.balanceOf(user);
        vm.prank(user);

        airdrop.claim(user , AMOUNT_TO_CLAIM , PROOF);
        uint256 endingBalance= token.balanceOf(user);

        console.log("Ending balance" , endingBalance);
        assertEq(endingBalance-startingbalance, AMOUNT_TO_CLAIM);

    }
    
}
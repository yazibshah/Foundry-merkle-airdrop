// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract MerkleAirdrop{

    using SafeERC20 for IERC20;
    // Custom error
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__alreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    // events
    event Claim(address account , uint256 amount);
    // some list of addresses and amounts
    address[] public claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account , uint256 amount)");

    struct AirdropClaim{
        address account ; 
        uint256 amount;
    }

    constructor(bytes32 merkleRoot, IERC20 airdropToken){
        i_merkleRoot = merkleRoot;
        i_airdropToken= airdropToken;
        // some logic to populate the claimers array
    }

    function claim(address account,uint256 amount , bytes32[] calldata merkleProof , uint8 v , bytes32 r , bytes32 s) external{
        if(s_hasClaimed[account]){
            revert MerkleAirdrop__alreadyClaimed();
        }

        if(!_isValidSignature(account , getMessage(account , amount) , v , r,s)){
            revert MerkleAirdrop__InvalidSignature(); 
        }
        bytes32 leaf=keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if(!MerkleProof.verify(merkleProof , i_merkleRoot , leaf)){
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account]=true;
        emit Claim(account , amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMessage(address account , uint256 amount) public view returns(bytes32){
        return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH ,AirdropClaim({account:account , amount: amount}))));
    }

    function getMerkleRoot() external view returns(bytes32){
        return i_merkleRoot;
    }
    
    function getAirdropToken() external view returns(IERC20){
        return i_airdropToken;
    }
}
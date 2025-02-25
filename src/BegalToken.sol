// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract BegalToken is ERC20, Ownable{
    // we will use the ERC20 contract from OpenZeppelin
    // to create Begal token

    constructor() ERC20("Begal Token", "BGL") Ownable(msg.sender) {     
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
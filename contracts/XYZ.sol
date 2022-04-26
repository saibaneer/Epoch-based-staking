//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract XYZ is ERC20 {

    constructor(uint initialSupply) ERC20("StakingToken", "XYZ"){
        _mint(msg.sender, initialSupply);
    }
    
}
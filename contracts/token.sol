// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';

contract xocolatl is ERC20Capped, ERC20Burnable {
    address payable public owner;
    uint256 public blockReward;

    constructor(uint256 maxSupply, uint256 reward) ERC20("xocolatl", "xoclt") ERC20Capped(maxSupply * (10 ** decimals())) {
        owner = payable(msg.sender);
        _mint(owner, 50000000 * (10 ** decimals())); 
        blockReward = reward * (10 ** decimals());
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    function _mintMinerReward() internal{
        _mint(block.coinbase, blockReward);
    }

    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override{
        if(from != address(0) && to != block.coinbase && block.coinbase != address(0)){
            _mintMinerReward();
        }
        super._beforeTokenTransfer(from, to, value); 
    }

    function setBlockReward(uint256 reward) public authOwner(){
        blockReward = reward * (10 ** decimals());
    }

    function destroy() public authOwner{
        selfdestruct(owner);
    }

    modifier authOwner() {
        require(msg.sender == owner, 'This request is available only to the owner of this smart contract' );
        _;
    } 

}
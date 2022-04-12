// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ERC20.sol";

contract Token {

    ERC20 erc20Contract;
    // uint256 supplyLimit;
    uint256 currentSupply;
    address owner;
    address payable escrow;

    constructor () public {

        ERC20 e = new ERC20();
        erc20Contract = e;
        owner = msg.sender;
        escrow = payable(address(this));
        // supplyLimit = 10000;
    }

    // minting DT
    function getCredit() public payable {
        uint256 amt = msg.value / 10000000000000000; //conversion from wei to eth
        erc20Contract.mint(msg.sender, amt);
    }

    // spending DT
    function transferCredit(address _to, uint256 _value) public {
        erc20Contract.transfer(_to, _value);
    }

    // transfering DT to  Escrow
    function transferToEscrow(address _from, uint256 _value) external {
        erc20Contract.transferFrom(_from, escrow,  _value);
    }

    // transfering DT from Escrow
    function transferFromEscrow(address _to, uint256 _value) external {
        erc20Contract.transferFrom(escrow, _to, _value);
    }


    // verify amount of DT
    function checkBalance(address _sender) public view returns (uint256) {
        return erc20Contract.balanceOf(_sender);
    }

    // verify amount of DT in escrow
    function checkBalanceEscrow() public view returns (uint256) {
        return erc20Contract.balanceOf(escrow);
    }
}
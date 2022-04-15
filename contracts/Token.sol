// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ERC20.sol";

contract Token {

    ERC20 erc20Contract;
    // uint256 supplyLimit;
    uint256 total_pool;
    address owner;

    constructor() public {

        ERC20 e = new ERC20();
        erc20Contract = e;
        owner = msg.sender;
        total_pool = 0;
    }

    mapping (address => uint256) frozenToken;

    event tokenFrozen(address _from, uint256 _value);
    event tokenReleased(address _from, address _to, uint256 _value);

    // minting DT
    function getCredit() public payable {
        uint256 amt = msg.value / 10000000000000000; //conversion from wei to eth
        erc20Contract.mint(tx.origin, amt);
        // erc20Contract.approve(tx.origin, amt);
        frozenToken[tx.origin] = 0;
    }

    function approveContractFunds(uint256 _value) public {
        require(erc20Contract.balanceOf(tx.origin) - frozenToken[tx.origin] >= _value, "You do not have sufficient funds to make fund this project");
        uint256 new_amt = getApproved(tx.origin, tx.origin) + _value;

        erc20Contract.approve(tx.origin, new_amt);
    }


    // transfering DT to  Escrow
    function transferToEscrow(address _from, uint256 _value) external {
        require(getApproved(tx.origin, tx.origin) - frozenToken[tx.origin] >= _value, "You do not have sufficient funds to make fund this project");
        frozenToken[_from] += _value;
        total_pool += _value;
        emit tokenFrozen(_from, _value);
    }

    // transfering DT from Escrow
    function transferFromEscrow( address _from,  address _to, uint256 _value) external {
        require(frozenToken[_from] >= _value, "Escrow has been breached. Please check");
        erc20Contract.transferFrom(_from, _to, _value);
        frozenToken[_from] -= _value;
        total_pool -= _value;
        emit tokenReleased(_from, _to, _value);
    }



    // verify amount of DT
    function checkBalance(address _sender) public view returns (uint256) {
        return erc20Contract.balanceOf(_sender);
    }

    // verify amount of DT
    function checkFrozen(address _sender) public view returns (uint256) {
        return frozenToken[_sender];
    }

    // verify amount of DT in escrow
    function checkBalancePool() public view returns (uint256) {
        return total_pool;
    }

    function getApproved(address _owner, address _spender) public view returns (uint256) {
        return erc20Contract.allowance(_owner, _spender);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


contract Profile {

    mapping (address => address) serviceProviderList;
    mapping (address => address) serviceRequesterList;

    struct profile {
        string name;
        string username;
        string password;
        address owner;
        uint256 creationValue;
    }

}
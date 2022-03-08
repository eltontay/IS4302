// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Profile {

    struct profile {
        string name;
        string username;
        string password;
        address owner;
    }

    mapping (address => profile) profileList; // list of profiles created in profile smart contract
    mapping (address => mapping(uint256 => uint256)) services; // list of profile addresses that contains a list of services provided
    mapping (address => mapping(uint256 => uint256)) servicesRequested; // list of profile addresses that contains a list of services requested

    uint256 public numProfile = 0;

    function createProfile(string memory name, string memory username, string memory password) public returns (uint256) {
        profile memory newProfile = profile(name,username,password,msg.sender);
        profileList[msg.sender] = newProfile;
        numProfile = numProfile ++;
        return numProfile;
    }

    function getName() public view returns ( string memory ) {
        return profileList[msg.sender].name;
    }

}
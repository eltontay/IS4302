// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Profile {


    // The main structure of the profile
    struct profile {
        string name;
        string username;
        string password;
        address owner;
        bool created;
    }

    event serviceCreated(bool successful);

    mapping (address => profile) profileList; // list of profiles created in profile smart contract
    mapping (address => mapping(uint256 => bool)) services; // list of profile addresses that contains a list of services provided
    mapping (address => mapping(uint256 => uint256)) servicesRequested; // list of profile addresses that contains a list of services requested

    uint256 public numProfile = 0; // To keep count of the number of profiles existing

    function createProfile(string memory name, string memory username, string memory password) public returns (uint256) {
        profile memory newProfile = profile(name,username,password,msg.sender,true);
        profileList[msg.sender] = newProfile;
        numProfile = numProfile ++;
        return numProfile;
    }

    modifier validProfile() {
        require(profileList[msg.sender].created);
        _;
    }

    // Getter for name of profile given that it is valid
    function getName() public validProfile() view returns ( string memory) {
        return profileList[msg.sender].name;
    }

    // Boolean function to check validity of profile
    function checkValidProfile() public view returns (bool) {
        return profileList[msg.sender].created ? true : false;
    }

    // Storing a created service
    function putService(uint256 serviceNumber) public {
        if (services[msg.sender][serviceNumber] == false) {
            services[msg.sender][serviceNumber] = true;
            emit serviceCreated(true);
        } else {
            emit serviceCreated(false);
        }
    }


}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// Profile smart contract serves just as a frontend , connected only to blocktractor

contract Profile {

    // The main structure of the profile
    struct profile {
        string name;
        string username;
        string password;
        address owner;
        bool created;
    }


    mapping (address => profile) profileList; // list of profiles created in profile smart contract

    uint256 public numProfile = 0; // To keep count of the number of profiles existing

   /*
        Profile - Create 
    */
    function createProfile(string memory name, string memory username, string memory password, address user)  external {
        require(profileList[user].created == false, "Cannot create more than 1 profile");
        profile memory newProfile = profile(name,username,password,user,true);
        profileList[user] = newProfile;
        numProfile = numProfile + 1;
    }

    /*
        Profile - Delete  
    */
    function deleteProfile(address user) external {
        require(profileList[user].created == true, "Profile does not exist");
        profileList[user].created = false; //soft delete 
        numProfile = numProfile - 1; 
    }

    /*
        Profile - Update  
    */
    function updateProfileName(string memory newName, address user) external {
        require(profileList[user].created == true, "Profile does not exist");
        profileList[user].name = newName; 
    }

    modifier validProfile {
        require(profileList[msg.sender].created == true);
        _;
    }

    // Getter for name of profile given that it is valid
    function getName() external validProfile view returns ( string memory) {
        return profileList[msg.sender].name;
    }

    // Boolean function to check validity of profile
    function checkValidProfile() public view returns (bool) {
        return profileList[msg.sender].created ? true : false;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// Profile smart contract serves just as a frontend , connected only to blocktractor

contract Profile {

    // The main structure of the profile
    struct profile {
        string name;
        string ownername;
        string password;
        address owner;
        bool created;
    }


    mapping (address => profile) profileList; // list of profiles created in profile smart contract

    uint256 public numProfile = 0; // To keep count of the number of profiles existing
    
    modifier validProfile (address owner) {
        require(profileList[owner].created == true, "Profile does not exist");
        _;
    }

    /*
        Profile - Create 
    */
    function createProfile(string memory name, string memory ownername, string memory password, address owner)  external {
        require(profileList[owner].created == false, "Cannot create more than 1 profile");
        profile memory newProfile = profile(name,ownername,password,owner,true);
        profileList[owner] = newProfile;
        numProfile = numProfile + 1;
    }

    /*
        Profile - Delete  
    */
    function deleteProfile(address owner) external validProfile (owner) {
        profileList[owner].created = false; //soft delete 
        numProfile = numProfile - 1; 
    }

    /*
        Profile - Update  
    */
    function updateProfileName(string memory newName, address owner) external validProfile (owner) {
        profileList[owner].name = newName; 
    }


    // Getter for name of profile given that it is valid
    function getName(address owner) external validProfile (owner) view returns ( string memory) {
        return profileList[owner].name;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Profile.sol";
import "./Service.sol";

contract Blocktractor {

    Profile profileContract;
    Service serviceContract;

    address _owner = msg.sender;
    uint256 public comissionFee;

    constructor(Profile profileAddress, Service serviceAddress, uint256 fee) public {
        comissionFee = fee;
        profileContract = profileAddress;
        serviceContract = serviceAddress;
    }

    // Verified Profiles are allowed to create service
    function createService(string memory title, string memory description, uint256 price) public payable { 
        require(profileContract.checkValidProfile(),'Your profile is not yet created');
        uint256 serviceNumber = serviceContract.createService(title,description,price);
        profileContract.putService(serviceNumber);
    }

    // Verified Profiles are allowed to list service
    function listService(uint256 serviceNumber) public {
        require(profileContract.checkValidProfile(),'Your profile is not yet created'); 
        serviceContract.listService(serviceNumber);
    }

    // Verified Profiles are allowed to delist service
    function delistService(uint256 serviceNumber) public {
        require(profileContract.checkValidProfile(),'Your profile is not yet created'); 
        serviceContract.delistService(serviceNumber);
    } 
    
    // Function that request listed Service
    function requestService() public {

    }

    // Function that approves requested listed service
    function approveService() public {

    }

    // Function that rejects requested listed service
    function rejectService() public {

    }

    // Function that completes listed Service
    function completeService() public {

    }

    // Getter for service status
    function statusService() public {
        
    }
    // Registering user profile on marketplace
    function registerProfile() public {

    }

    // Removing user profile on marketplace
    function removeProfile() public {

    }


}
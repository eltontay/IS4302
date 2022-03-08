// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Profile.sol";
import "./Service.sol";


contract Blocktractor {

    address _owner = msg.sender;
    uint256 public comissionFee;
    mapping (string => string) profileList;
    mapping (uint256 => uint256) serviceContractList;

    constructor(uint256 fee) {
        comissionFee = fee;
    }

    // Verified Profiles are allowed to list service
    function listService() public {

    }

    // Verified Profiles are allowed to delist service
    function delistService() public {

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
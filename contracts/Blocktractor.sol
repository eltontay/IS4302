// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Profile.sol";
import "./Service.sol";

contract Blocktractor {

    Profile profileContract;
    Service serviceContract;

    address payable escrow_wallet; // = payable(msg.sender);
    address payable revenue_wallet; // = payable(msg.sender);
    uint256 public comissionFee;

    constructor(Profile profileAddress, Service serviceAddress, uint256 fee) public {
        comissionFee = fee;
        profileContract = profileAddress;
        serviceContract = serviceAddress;
        escrow_wallet = payable(msg.sender);
        revenue_wallet = payable(msg.sender);
    }

    // Verified Profiles are allowed to create service
    function createService(string memory title, string memory description, uint256 price) public payable { 
        serviceContract.create(title,description,price);
    }

    // Verified Profiles are allowed to list service
    function listService(uint256 serviceNumber) public {
        serviceContract.listService(serviceNumber);
    }

    // Verified Profiles are allowed to delist service
    function delistService(uint256 serviceNumber) public {
        serviceContract.delistService(serviceNumber);
    } 
    
    // Requesting for a service
    function requestService(uint256 serviceNumber) public {
        serviceContract.requestService(serviceNumber);
    }

    // Cancelling requested service
    function cancelRequestService(uint256 serviceNumber) public {
        serviceContract.cancelRequestService(serviceNumber);
    }

    // Approving requested service request
    function approveService(uint256 serviceNumber) public {
        serviceContract.approveServiceRequest(serviceNumber);
    }

    // Reject requested service request
    function rejectService(uint256 serviceNumber) public {
        serviceContract.rejectServiceRequest(serviceNumber);
    }

    // 
    function startRequestedService(uint256 serviceNumber) public payable {
        require(msg.value >= (serviceContract.getServicePrice(serviceNumber) + comissionFee), "Insufficient gas provided");
        require(serviceContract.isServiceApproved(serviceNumber),"Service is not approved");
        revenue_wallet.transfer(comissionFee);
        escrow_wallet.transfer(msg.value-comissionFee);
        serviceContract.startRequestedService(serviceNumber);
    }

    // Function that completes listed Service
    function completeService(uint256 serviceNumber) public {
        // Service provider completes service
        serviceContract.completeService(serviceNumber);
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
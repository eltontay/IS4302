// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Profile.sol";
import "./Service.sol";

contract Blocktractor {

    event serviceListed(uint256 serviceNumber);
    event serviceDelisted(uint256 serviceNumber);

    Profile profileContract;
    Service serviceContract;

    uint256[] listedServices; // list of listed services (by serviceNumber)

    address payable escrow_wallet = payable(msg.sender);
    address payable revenue_wallet = payable(msg.sender);
    uint256 public comissionFee;

    constructor(Profile profileAddress, Service serviceAddress, uint256 fee) public {
        comissionFee = fee;
        profileContract = profileAddress;
        serviceContract = serviceAddress;
    }

    modifier onlyServiceProvider(uint256 serviceNumber){
        // only allow service providers to perform the action
        require(msg.sender == serviceContract.getServiceProvider(serviceNumber), "Only Service Providers can perform this action");
        _;
    }

    modifier listedService(uint256 serviceNumber){
        require(isListed(serviceNumber) == true,"Service is not listed");
        _;
    }

    modifier notListedService(uint256 serviceNumber){
        require(isListed(serviceNumber) == false,"Service is already listed");
        _;
    }

    // Verified Profiles are allowed to create service
    /*function createService(string memory title, string memory description, uint256 price) public payable { 
        serviceContract.createService(title,description,price);
    }

    function deleteService(uint256 serviceNumber) public{
        serviceContract.deleteService(serviceNumber);
    }*/

    // Verified Profiles are allowed to list service
    function listService(uint256 serviceNumber) public onlyServiceProvider(serviceNumber) notListedService(serviceNumber) {
        //serviceContract.listService(serviceNumber);

        listedServices.push(serviceNumber);
        emit serviceListed(serviceNumber);
    }

    // Verified Profiles are allowed to delist service
    function delistService(uint256 serviceNumber) public onlyServiceProvider(serviceNumber) listedService(serviceNumber) {
        //serviceContract.delistService(serviceNumber);
        // Ensure that service is listed
        uint256 i;
        for(i = 0; i < listedServices.length; i++){
            if (listedServices[i] == serviceNumber){
                break;
            }
        }

        // Remove element from listedServices array
        for(uint256 j = i; j < listedServices.length-1; j++){
            listedServices[j] = listedServices[j+1]; //decrement the index
        }
        listedServices.pop(); // the last element is not supposed to be there

        emit serviceDelisted(serviceNumber);
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

    /* Getter Functions */

    function isListed(uint256 serviceNumber) public view returns (bool){
        bool listed = false;
        for(uint256 i = 0; i < listedServices.length; i++){
            if (listedServices[i] == serviceNumber){
                listed=true;
                break;
            }
        }
        return listed;
    }

}
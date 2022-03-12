// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Service {

    enum Status { none, pending, approved, started, completed, incomplete }
    enum Review { none, satisfied, disatisfied }

    struct milestone {
        uint256 milestoneNumber;
        string milestoneTitle;
        string milestoneDescription;
        Review review; // Defaults at none
    }
    
    struct service {
        string title;
        string description;
        uint256 price;
        uint256 totalMilestones; // Defaults to 1 milestone
        uint256 currentMilestone; // Defaults to 0 milestone
        uint256 serviceNumber; // index number of the service
        address serviceProvider; // msg.sender
        address serviceRequester; // defaults to address(0)
        Status status; // Defaults at none
        bool listed;  // Defaults at false
        Review review; // Overall review of services, defaults at none
    }

    event serviceCreated(uint256 serviceNumber);
    event serviceDeleted(uint256 serviceNumber);
    event serviceListed(uint256 serviceNumber);
    event serviceDelisted(uint256 serviceNumber);
    event serviceRequested(Status status);
    event serviceCancelRequest(Status status);
    event serviceApproved(Status status);
    event serviceRejected(Status status);
    event serviceStarted(Status status);

    mapping (uint256 => mapping(uint256 => milestone)) milestones; // indexed mapping of services to multiple milestones
    mapping (uint256 => service) services; // indexed mapping of all services 
    
    uint256 public numService = 0;
    
    // Creation of service
    function createService (string memory title, string memory description, uint256 price) public returns (uint256) {
        require(bytes(title).length > 0, "A Service Title is required");
        require(bytes(description).length > 0, "A Service Description is required");
        require(price > 0, "A Service Price must be specified");
        
        service memory newService = service(title,description,price,1,0,numService,msg.sender,address(0),Status.none,false,Review.none);
        services[numService] = newService;
        emit serviceCreated(numService);
        numService = numService++;
        return numService;
    }

    // Deletion of service 
    function deleteService (uint256 serviceNumber) public {
        require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider");
        // replacing deleted spot with the last element in the list
        services[serviceNumber] = services[numService-1];
        // deleting the last element in the list
        delete services[numService-1];
        emit serviceDeleted(serviceNumber);
        numService -= 1; 
    }

    // Service provider listing created service
    function listService (uint256 serviceNumber) public {
        require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider");
        services[serviceNumber].listed = true;
        emit serviceListed(serviceNumber);
    }

    // Service provider delisting created service
    function delistService (uint256 serviceNumber) public {
        require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider");
        services[serviceNumber].listed = false; 
        emit serviceDelisted(serviceNumber);
    }

    // Service requester requesting service
    function requestService (uint256 serviceNumber) public {
        require(services[serviceNumber].serviceRequester == address(0), "This service has been requested already.");
        services[serviceNumber].serviceRequester = msg.sender;
        services[serviceNumber].status = Status.pending; // signify pending service request
        emit serviceRequested(Status.pending);
    }

    // Service requester cancelling service request
    function cancelRequestService (uint256 serviceNumber) public {
        require(services[serviceNumber].serviceRequester == msg.sender, "Unauthorised cancel of service request");
        services[serviceNumber].serviceRequester = address(0);
        services[serviceNumber].status = Status.none; // reverting back to original status state
        emit serviceCancelRequest(Status.none);
    }

    // Service provider approving pending service request
    function approveServiceRequest(uint256 serviceNumber) public {
        require(services[serviceNumber].serviceProvider == msg.sender, "Unauthorised approval of service request");
        services[serviceNumber].status = Status.approved; // Changing state to accepted
        emit serviceApproved(Status.approved);
    }

    // Service provider rejecting pending service request
    function rejectServiceRequest(uint256 serviceNumber) public {
        require(services[serviceNumber].serviceProvider == msg.sender, "Unauthorised rejection of service request");
        services[serviceNumber].status = Status.none; // reverting back to original status state
        emit serviceRejected(Status.none);
    }

    // Service requester can now start the requested service
    function startRequestedService(uint256 serviceNumber) public {
        require(services[serviceNumber].serviceProvider == msg.sender, "Unauthorised starting of service request");
        services[serviceNumber].status = Status.started;
        emit serviceStarted(Status.started);
    }




    // Getter for services created by service provider
    function viewMyServices() public view returns (string memory) {
        string memory s = "";
        for (uint i = 0; i < numService; i++) {
            if (services[i].serviceProvider == msg.sender) {
                s = string(abi.encodePacked(s, ' ', Strings.toString(numService)));
            }
        }
        return s;
    }

    // Getter for total number of services listed
    function getNumServices() public view returns (uint256) {
        return numService;
    }

    // Getter for service details
    function getServiceDetails(uint256 serviceNumber) public view returns (service memory) {
        return services[serviceNumber];
    }

    // Getter for service price
    function getServicePrice(uint256 serviceNumber) public view returns (uint256) {
        return services[serviceNumber].price;
    }

    // Getter for boolean if service is approved
    function isServiceApproved(uint256 serviceNumber) public view returns (bool) {
        return services[serviceNumber].status == Status.approved;
    }
}
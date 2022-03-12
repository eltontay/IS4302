// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Service {

    enum Status { none, pending, approved, started, completed }
    enum Review { none, satisfied, disatisfied }

    struct milestone {
        string milestoneTitle;
        string milestoneDescription;
        bool exist; // allowing updates such as soft delete of milestone   
        Status status; // Defaults at none
        Review review; // Defaults at none
    }
    
    struct service {
        string title;
        string description;
        uint256 price;
        uint256 totalMilestones; // Defaults to 1 milestone
        uint256 currentMilestone; // Defaults to 0 milestone
        uint256 milestoneCounter; // Counter to keep track of milestones that exist
        uint256 serviceNumber; // index number of the service
        address serviceProvider; // msg.sender
        address serviceRequester; // defaults to address(0)
        bool listed;  // Defaults at false
        bool exist; // allowing update such as soft delete of service
        Status status; // Defaults at none
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
    event serviceCompleted(Status status);
    event serviceReview(Review review);
    event milestoneAdded(uint256 serviceNumber, uint256 milestoneNumber, string milestoneTitle, string milestoneDescription);
    event milestoneDeleted(uint256 serviceNumber, uint256 milestoneNumber);
    event milestoneCompleted(uint256 serviceNumber, uint256 milestoneNumber);
    event milestoneReview(Review review);

    mapping (uint256 => mapping(uint256 => milestone)) milestones; // indexed mapping of services to multiple milestones
    mapping (uint256 => service) services; // indexed mapping of all services 
    
    uint256 public numService = 0;


/*
    Service Provider Functions
*/

    // Creation of service , defaults at 1 milestone. To add more milestones, use AddMilestones function
    function createService (string memory title, string memory description, uint256 price) public returns (uint256) {
        require(bytes(title).length > 0, "A Service Title is required");
        require(bytes(description).length > 0, "A Service Description is required");
        require(price > 0, "A Service Price must be specified");
        
        service memory newService = service(title,description,price,0,0,0,numService,msg.sender,address(0),false,true,Status.none,Review.none);
        addMilestone(numService, title, description); // Defaults first milestone to equivalent to original title and description
        services[numService] = newService;
        emit serviceCreated(numService);
        numService = numService++;
        return numService;
    }

    // Deletion of service
    function deleteService (uint256 serviceNumber) public {
        require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider");
        services[serviceNumber].exist = false;
        emit serviceDeleted(serviceNumber);
    }

    // Adding milestone , starts from 2nd milestone (index 2)
    function addMilestone (uint256 serviceNumber, string memory milestoneTitle, string memory milestoneDescription ) public {
        require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider");
        services[serviceNumber].totalMilestones += 1; // Real tally of total milestones
        services[serviceNumber].milestoneCounter += 1; // A counter that only increments
        uint256 serviceMilestone = services[serviceNumber].totalMilestones;
        milestones[serviceNumber][serviceMilestone] = milestone(milestoneTitle,milestoneDescription,true,Status.none,Review.none);
        emit milestoneAdded(serviceNumber, serviceMilestone, milestoneTitle, milestoneDescription);
    }

    // Deleting milestone , soft delete with a boolean function
    function deleteMilestone (uint256 serviceNumber, uint256 milestoneNumber) public {
        require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider"); 
        milestones[serviceNumber][milestoneNumber].exist = false;
        services[serviceNumber].totalMilestones -= 1; // Real tally of total milestones
        emit milestoneDeleted(serviceNumber, milestoneNumber);
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

    function completeMilestone(uint256 serviceNumber, uint256 milestoneNumber) public {
        require(services[serviceNumber].serviceProvider == msg.sender, "Unauthorised starting of service request");
        milestones[serviceNumber][milestoneNumber].status = Status.completed;
        emit milestoneCompleted(serviceNumber, milestoneNumber);
        services[serviceNumber].currentMilestone += 1;
        completeService(serviceNumber); // complete service if all milestones are finished
    }

    function completeService(uint256 serviceNumber) public {
        require(services[serviceNumber].serviceProvider == msg.sender, "Unauthorised starting of service request");
        if (services[serviceNumber].currentMilestone == services[serviceNumber].totalMilestones) {
            services[serviceNumber].status = Status.completed;
            emit serviceCompleted(Status.completed);
        }      
    }

/*
    Service Requester Functions
*/

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

    // Service requester can now start the requested service
    function startRequestedService(uint256 serviceNumber) public {
        require(services[serviceNumber].serviceRequester == msg.sender, "Unauthorised starting of service request");
        services[serviceNumber].status = Status.started;
        emit serviceStarted(Status.started);
    }

    // Review of service takes in a a boolean, true = satisfied, false = dissatisfied
    function reviewMilestone(uint256 serviceNumber, uint256 milestoneNumber, bool satisfied) public {
        require(services[serviceNumber].serviceRequester == msg.sender, "Unauthorised review of service");
        if (satisfied) {
            milestones[serviceNumber][milestoneNumber].review = Review.satisfied;
            emit milestoneReview(Review.satisfied);
        } else {
            milestones[serviceNumber][milestoneNumber].review = Review.disatisfied;
            emit milestoneReview(Review.disatisfied);
        }
    }

    // Review of service takes in a boolean, true = satisfied , false = dissatisfied
    function reviewService(uint256 serviceNumber, bool satisfied) public {
        require(services[serviceNumber].serviceRequester == msg.sender, "Unauthorised review of service");
        satisfied ? services[serviceNumber].review = Review.satisfied : services[serviceNumber].review = Review.disatisfied;
    }

/*
    Getter Helper Functions
*/

    // Getter for services created by service provider
    function viewMyServices() public view returns (string memory) {
        string memory s = "";
        for (uint i = 0; i < numService; i++) {
            if (services[i].serviceProvider == msg.sender) {
                s = string(abi.encodePacked(s, ' ', Strings.toString(i)));
            }
        }
        return s;
    }

    // Getter for index milestones in the service
    function getMilestones(uint256 serviceNumber) public view returns (string memory) {
        string memory s = "";
        for (uint i = 0; i < services[serviceNumber].milestoneCounter; i++) {
            if (milestones[serviceNumber][i].exist == true) {
                s = string(abi.encodePacked(s,' ', Strings.toString(i)));
            }
        }
        return s;
    }

    // Getter for total milestones in the service
    function getTotalMilestones(uint256 serviceNumber) public view returns (uint256) {
        return services[serviceNumber].totalMilestones;
    }
    
    // Getter for total number of services listed
    function getNumServices() public view returns (uint256) {
        uint sum = 0;
        for (uint i = 0 ; i < numService; i ++) {
            services[i].exist == true ? sum += 1 : sum += 0;
        }
        return sum;
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
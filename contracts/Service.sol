// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Service {

    /**
    State diagram for Status
    None -> pending -> approved -> started -> completed
     ^         |
     |_________|
    */
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
        //bool listed;  // Defaults at false
        bool exist; // allowing update such as soft delete of service
        Status status; // Defaults at none
        Review review; // Overall review of services, defaults at none
    }

    event serviceCreated(uint256 serviceNumber);
    event serviceDeleted(uint256 serviceNumber);
    //event serviceListed(uint256 serviceNumber);
    //event serviceDelisted(uint256 serviceNumber);
    event serviceStatusChanged(uint256 serviceNumber, Status statusBefore, Status statusAfter);
    /*event serviceRequested(Status status, uint256 serviceNumber);
    event serviceCancelRequest(Status status);
    event serviceApproved(Status status);
    event serviceRejected(Status status);
    event serviceStarted(Status status);
    event serviceCompleted(Status status);*/
    event serviceReview(Review review);
    event milestoneStatusChanged(uint256 serviceNumber, uint256 milestoneNumber, Status statusBefore, Status statusAfter);
    event milestoneCreated(milestone newMilestone);
    event milestoneAdded(uint256 serviceNumber, uint256 milestoneNumber, milestone newMilestone);
    event milestoneDeleted(uint256 serviceNumber, uint256 milestoneNumber);
    event milestoneCompleted(uint256 serviceNumber, uint256 milestoneNumber);
    event milestoneReview(Review review);

    mapping (uint256 => mapping(uint256 => milestone)) milestones; // indexed mapping of services to multiple milestones
    mapping (uint256 => service) services; // indexed mapping of all services 
    
    uint256 public numService = 0;
    modifier requiredString(string memory str){
        require(bytes(str).length > 0, "A string is required!");
        _;
    }

    modifier onlyServiceProvider(uint256 serviceNumber){
        // Only allow ServiceProviders to access these functions
        require(msg.sender == services[serviceNumber].serviceProvider, 
                "Unauthorised access to service, only service provider can access");
        _;
    }

    modifier onlyServiceRequester(uint256 serviceNumber){
        // Only allow Service Requesters to access these functions
        require(msg.sender == services[serviceNumber].serviceRequester, 
                "Unauthorised access to service, only service requester can access");
        _;
    }

    modifier hasServiceStatus(uint256 serviceNumber, Status state){
        require(services[serviceNumber].status == state);
        _;
    }

    modifier hasServiceStatuses(uint256 serviceNumber, Status state1, Status state2){
        // for multiple states
        require(services[serviceNumber].status == state1 ||services[serviceNumber].status == state2 );
        _;
    }

    modifier hasMilestoneStatus(uint256 serviceNumber, uint256 milestoneNumber, Status state){
        require(milestones[serviceNumber][milestoneNumber].status == state);
        _;
    }

    modifier allMilestonesApproved(uint256 serviceNumber){
        uint256 numApproved = 0;
        uint256 numMilestones = services[serviceNumber].milestoneCounter;
        // Find the total number of approved milestones associated with the service.
        // It must be the same as the total milestones stated in the service.
        for(uint256 i = 0; i < numMilestones; i++){
            if (milestones[serviceNumber][i].status == Status.none){
                continue;
            } else if (milestones[serviceNumber][i].status == Status.approved){
                numApproved++;
            }
        }
        require(numApproved == services[serviceNumber].totalMilestones, "All milestones must be approved first!");
        _;
    }

    modifier allMilestonesComplete(uint256 serviceNumber){
        require(allMilestonesCompleted(serviceNumber) == true, "Not all milestones are completed!");
        _;
    }

/*
    Service Provider Functions
*/
    // Creation of service , defaults at 1 milestone. To add more milestones, use AddMilestones function
    function createService(string memory title, string memory description, uint256 price) public 
            requiredString(title)        /// Service Title cannot be empty
            requiredString(description)  /// Service Description cannot be empty
    returns (uint256) {
        //require(bytes(title).length > 0, "A Service Title is required");
        //require(bytes(description).length > 0, "A Service Description is required");
        require(price > 0, "A Service Price must be specified");
        
        service memory newService = service(title,description,price,0,0,0,numService,msg.sender,address(0),true,Status.none,Review.none);
        services[numService] = newService;
        addMilestone(numService, title, description); // Defaults first milestone to equivalent to original title and description
        emit serviceCreated(numService);
        numService++;
        
        return numService;
    }

    // Deletion of service (soft deletion)
    function deleteService(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber) /// Only Service Providers can delete service
        {
        //require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider");
        services[serviceNumber].exist = false;
        emit serviceDeleted(serviceNumber);
    }

    // Adding milestone , starts from 2nd milestone (index 2):
    function addMilestone (uint256 serviceNumber, string memory milestoneTitle, string memory milestoneDescription ) public 
            onlyServiceProvider(serviceNumber)                             /// Only Service Providers can add milestone
            hasServiceStatuses(serviceNumber, Status.pending, Status.none) /// Only Services that are not approved yet can have milestones added. 
                                                                           /// Milestones must be added before the service is approved.
            requiredString(milestoneTitle)                                 /// Milestone Title can  not be empty.
            requiredString(milestoneDescription)                           /// Milestone Description cannot be empty.
        {
        // require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider");
        services[serviceNumber].totalMilestones += 1; // Real tally of total milestones
        services[serviceNumber].milestoneCounter += 1; // A counter that only increments
        uint256 serviceMilestone = services[serviceNumber].milestoneCounter; // This acts as the 'id' of the milestone
        
        // milestones are created with default pending status
        milestone memory newMilestone = milestone(milestoneTitle,milestoneDescription,true,Status.pending,Review.none);
        emit milestoneCreated(newMilestone);

        milestones[serviceNumber][serviceMilestone] = newMilestone;
        emit milestoneAdded(serviceNumber, serviceMilestone, newMilestone);
    }

    // Deleting milestone , soft delete with a boolean function:
    function deleteMilestone (uint256 serviceNumber, uint256 milestoneNumber) public 
            onlyServiceProvider(serviceNumber)                                  /// Only Service Providers can delete milestone
            hasServiceStatuses(serviceNumber, Status.pending, Status.none)      /// Only Services that are not approved yet can have milestones deleted. 
                                                                                /// Milestones must be deleted before the service is approved.
            hasMilestoneStatus(serviceNumber, milestoneNumber, Status.pending)  /// Only milestones that are pending can be deleted.
        {
        // require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider"); 
        milestones[serviceNumber][milestoneNumber].exist = false;
        Status before = milestones[serviceNumber][milestoneNumber].status;
        milestones[serviceNumber][milestoneNumber].status = Status.none;
        emit milestoneStatusChanged(serviceNumber, milestoneNumber, before, Status.none);

        services[serviceNumber].totalMilestones -= 1; // Real tally of total milestones
        emit milestoneDeleted(serviceNumber, milestoneNumber);
    }

    // Service provider listing created service
    /*function listService (uint256 serviceNumber) public onlyServiceProvider(serviceNumber){
        // require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider");
        services[serviceNumber].listed = true;
        emit serviceListed(serviceNumber);
    }

    // Service provider delisting created service
    function delistService (uint256 serviceNumber) public onlyServiceProvider(serviceNumber){
        // require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised service provider");
        services[serviceNumber].listed = false; 
        emit serviceDelisted(serviceNumber);
    }*/

    // Service provider approving pending service request.
    function approveServiceRequest(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber)              /// Only Service Providers can approve service request
            hasServiceStatus(serviceNumber, Status.pending) /// Only Services that are Pending can be approved
            allMilestonesApproved(serviceNumber)            /// Service can only be approved once all milestones are approved
        {
        // require(services[serviceNumber].serviceProvider == msg.sender, "Unauthorised approval of service request");
        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.approved; // Changing state to accepted
        //emit serviceApproved(Status.approved);
        emit serviceStatusChanged(serviceNumber, before, Status.approved);
    }

    // Service provider rejecting pending service request.
    function rejectServiceRequest(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber)              /// Only Service Providers can Reject Service Request
            hasServiceStatus(serviceNumber, Status.pending) /// Only Services that are Pending can be Rejected
        {
        // require(services[serviceNumber].serviceProvider == msg.sender, "Unauthorised rejection of service request");
        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.none; // reverting back to original status state
        //emit serviceRejected(Status.none);
        emit serviceStatusChanged(serviceNumber, before, Status.none);
    }

    // Service Provider can now start the requested service. Only approved services can start
    function startRequestedService(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber)               /// Only Service Provider can Start Service
            hasServiceStatus(serviceNumber, Status.approved) /// Only Services that are Approved can be Started.
        {
        //require(services[serviceNumber].serviceRequester == msg.sender, "Unauthorised starting of service request");
        // Check for only service requester being able to start is done in Blocktractor contract
        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.started;
        // emit serviceStarted(Status.started);
        emit serviceStatusChanged(serviceNumber, before, Status.started);

        // Find the first unfinished milestone and change the status to started
        uint256 unfinished = getNextMilestone(serviceNumber, services[serviceNumber].currentMilestone);
        Status milestoneStatus = milestones[serviceNumber][unfinished].status ;
        milestones[serviceNumber][unfinished].status = Status.started;
        emit milestoneStatusChanged(serviceNumber, unfinished, milestoneStatus, Status.started);
    }

    // Only services that have been started can have milestones completed 
    function completeMilestone(uint256 serviceNumber, uint256 milestoneNumber) public 
            onlyServiceProvider(serviceNumber)                                 /// Only Service Providers can Complete Milestone
            hasServiceStatus(serviceNumber, Status.started)                    /// Only Services that have Started can Complete Milestone
            hasMilestoneStatus(serviceNumber, milestoneNumber, Status.started) /// Only Milestones that have Started can be Completed
        {
        // require(services[serviceNumber].serviceProvider == msg.sender, "Unauthorised starting of service request");
        Status before = milestones[serviceNumber][milestoneNumber].status;
        milestones[serviceNumber][milestoneNumber].status = Status.completed;
        emit milestoneStatusChanged(serviceNumber, milestoneNumber, before, Status.completed);
        
        if(allMilestonesCompleted(serviceNumber)){
            // complete service
            completeService(serviceNumber);
        } else{
            // Automatically start the next milestone
            uint256 currentMilestone = services[serviceNumber].currentMilestone;
            // Find the next milestone and start it
            uint256 nextMilestone = getNextMilestone(serviceNumber, currentMilestone);
            Status milestoneStatus = milestones[serviceNumber][nextMilestone].status ;
            milestones[serviceNumber][nextMilestone].status = Status.started;
            emit milestoneStatusChanged(serviceNumber, nextMilestone, milestoneStatus, Status.started);
            
            // The nextMilestone is the milestone that the service provider is currently working on
            services[serviceNumber].currentMilestone = nextMilestone;
        }
        // completeService(serviceNumber); // complete service if all milestones are finished
    }

    // Only Services that have been started can be completed 
    function completeService(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber)              /// Only Service Providers can Complete Service
            hasServiceStatus(serviceNumber, Status.started) /// Only Services that have Started can Complete
            allMilestonesComplete(serviceNumber)            /// Service can only be completed once all milestones are completed
        {
        // require(services[serviceNumber].serviceProvider == msg.sender, "Unauthorised starting of service request");
        // if (services[serviceNumber].currentMilestone == services[serviceNumber].totalMilestones) {
        //     Status before = services[serviceNumber].status;
        //     services[serviceNumber].status = Status.completed;
        //     emit serviceStatusChanged(serviceNumber, before, Status.completed);
        // }
        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.completed;
        emit serviceStatusChanged(serviceNumber, before, Status.completed);
    }

/*
    Service Requester Functions
*/
    // Service requester requesting service. Service must have a status of none
    function requestService (uint256 serviceNumber) public 
            hasServiceStatus(serviceNumber, Status.none) /// Only Services that are newly created can be requested. i.e not approved by any other provider.
        {
        require(services[serviceNumber].serviceRequester == address(0), "This service has been requested already.");
        // Change the serviceRequester to the sender
        services[serviceNumber].serviceRequester = msg.sender;

        //  Change the service status to pending
        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.pending; // signify pending service request
        // emit serviceRequested(Status.pending, serviceNumber);
        emit serviceStatusChanged(serviceNumber, before, Status.pending);
    }

    // Service requester cancelling service request. 
    // Only pending statuses can be cancelled this way. If approved, started, completed, will have dispute.
    function cancelRequestService (uint256 serviceNumber) public 
            onlyServiceRequester(serviceNumber)             /// Only Service Requesters can cancel Request Service
            hasServiceStatus(serviceNumber, Status.pending) /// Only Services that are Pending can be Cancelled.
        {
        //require(services[serviceNumber].serviceRequester == msg.sender, "Unauthorised cancel of service request");
        services[serviceNumber].serviceRequester = address(0);
        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.none; // reverting back to original status state
        //emit serviceCancelRequest(Status.none);
        emit serviceStatusChanged(serviceNumber, before, Status.none);
    }

    function interruptService(uint256 serviceNumber) public {
        // TODO: service provider/requester interrupting the service any time after it has been approved.
        // This leads to a dispute.
        // Should this be in blocktractor.sol?
        // the function here should only have the logic where the service is concerned. change of service state? 
        // the dispute resolution shall be done in blocktractor.sol
    }

    // Service requester to approve milestones set by service provider. 
    function approveMilestone(uint256 serviceNumber, uint256 milestoneNumber) public 
            onlyServiceRequester(serviceNumber)                                /// Only Service Requesters can approve Milestones
            hasMilestoneStatus(serviceNumber, milestoneNumber, Status.pending) /// Only milestones that are pending can be approved
    {
        Status before = milestones[serviceNumber][milestoneNumber].status;
        milestones[serviceNumber][milestoneNumber].status = Status.completed;
        emit milestoneStatusChanged(serviceNumber, milestoneNumber, before, Status.approved);
    }

    // Review of service takes in a a boolean, true = satisfied, false = dissatisfied TODO
    function reviewMilestone(uint256 serviceNumber, uint256 milestoneNumber, bool satisfied) public 
            onlyServiceRequester(serviceNumber)    /// Only Service Requesters can cancel Review Milestone
        {
        //require(services[serviceNumber].serviceRequester == msg.sender, "Unauthorised review of service");
        if (satisfied) {
            milestones[serviceNumber][milestoneNumber].review = Review.satisfied;
            emit milestoneReview(Review.satisfied);
        } else {
            milestones[serviceNumber][milestoneNumber].review = Review.disatisfied;
            emit milestoneReview(Review.disatisfied);
        }
    }

    // Review of service takes in a boolean, true = satisfied , false = dissatisfied TODO
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

    // Getter to get the next milestone that is not complete.
    function getNextMilestone(uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint256){
        for (uint256 i = milestoneNumber+1; i < services[serviceNumber].milestoneCounter; i++){
            if(milestones[serviceNumber][i].status == Status.approved){
                return i;
            }
        }
        return services[serviceNumber].milestoneCounter; // To indicate that all milestones have been completed.
    }
    
    // Getter to check if all milestones have been completed.
    function allMilestonesCompleted(uint256 serviceNumber) public view returns (bool){
        return getNextMilestone(serviceNumber, 0) == services[serviceNumber].milestoneCounter ? true : false;
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

    // Getter for boolean if service exists
    function doesServiceExist(uint256 serviceNumber) public view returns (bool){
        return services[serviceNumber].exist;
    }

    // Getter for Service provider
    function getServiceProvider(uint256 serviceNumber) public view returns (address){
        return services[serviceNumber].serviceProvider;
    }

    // Getter for Service requester
    function getServiceRequester(uint256 serviceNumber) public view returns (address){
        return services[serviceNumber].serviceRequester;
    }
    // Getter for boolean if milestone is approved
    function isMilestoneApproved(uint256 serviceNumber, uint256 milestoneNumber) public view returns (bool) {
        return milestones[serviceNumber][milestoneNumber].status == Status.approved;
    }

}
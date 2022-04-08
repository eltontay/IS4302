// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Milestone.sol";
import "./Conflict.sol";
import "./Project.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract ServiceOld {
    
    Milestones milestoneContract;  
    Conflict conflictContract;  
    Project projectContract;  

    constructor(Milestones milestoneAddress, Conflict conflictAddress, Project projectAddress) public {
        milestoneContract = milestoneAddress;
        conflictContract = conflictAddress;
        projectContract = projectAddress;
    }

    /**
    State diagram for Status
    None -> pending -> approved -> started -> completed
     ^         |
     |_________|
    */

    enum Status { none, pending, approved, started, completed, conflict }
    
    struct service {
        uint256 projectid;
        string title;
        string description;
        uint256 price;
        uint256 currentMilestone; // Defaults to 0 milestone
        uint256 serviceNumber; // index number of the service
        address serviceProvider; // msg.sender
        address serviceRequester; // defaults to address(0)
        bool exist; // allowing update such as soft delete of service
        Status status; // Defaults at none
    }

    event serviceCreated(uint256 serviceNumber, service newService);
    event serviceDeleted(uint256 serviceNumber);
    event serviceStatusChanged(uint256 serviceNumber, Status statusBefore, Status statusAfter);

    event serviceRequested(Status status, uint256 serviceNumber);
    event serviceCancelRequest(Status status);
    event serviceApproved(Status status);
    event serviceRejected(Status status);
    event serviceStarted(Status status);
    event serviceCompleted(Status status);

    mapping (uint256 => service) services; // indexed mapping of all services   

    uint256 public numService = 0;


/*
    Modifiers
*/

    modifier requiredString(string memory str){
        require(bytes(str).length > 0, "A string is required!");
        _;
    }

    modifier onlyServiceProvider(uint256 serviceNumber){ // Only allow ServiceProviders to access these functions
        require(msg.sender == services[serviceNumber].serviceProvider, "Unauthorised access to service, only service provider can access");
        _;
    }

    modifier onlyServiceRequester(uint256 serviceNumber){ // Only allow Service Requesters to access these functions
        require(msg.sender == services[serviceNumber].serviceRequester, "Unauthorised access to service, only service requester can access");
        _;
    }

    modifier onlyNonServiceProvider(uint256 serviceNumber){ // Only allow None Service Providers to access these functions
        require(msg.sender != services[serviceNumber].serviceProvider, "Unauthorised access to service, only service requester can access");
        _;
    }

    modifier hasServiceStatus(uint256 serviceNumber, Status state) {
        require(services[serviceNumber].status == state, "The status of this service does not match the intended status.");
        _;
    }

    modifier hasServiceStatuses(uint256 serviceNumber, Status state1, Status state2) { // for multiple states
        require(services[serviceNumber].status == state1 ||services[serviceNumber].status == state2, "This service is currently active and underway. No changes should be made to milestones or services.");
        _;
    }

    modifier hasServiceStatusBeforeStarted(uint256 serviceNumber) { 
        require(uint8(services[serviceNumber].status) < 3 , "This service has already started. No changes should be made to milestones or services.");
        _;
    }

    modifier activeService(uint256 serviceNumber) {
        require(services[serviceNumber].exist == true, "This service has been deleted and does not exist anymore");
        _;
    }

    modifier hasMilestoneStatus(uint256 serviceNumber, uint256 milestoneNumber, Status state){
        require(milestoneContract.checkMilestoneStatus(serviceNumber, milestoneNumber, uint8(state)), "Milestone status does not match.");
        _;
    }

    modifier hasMilestoneStatusCompleted(uint256 serviceNumber, uint256 milestoneNumber){
        require(milestoneContract.checkMilestoneStatus(serviceNumber, milestoneNumber, 4), "Milestone has not been completed by Service Provider yet. Please do not verify an uncompleted milestone.");
        _;
    }

    modifier hasMileStoneStatusVerified(uint256 serviceNumber, uint256 milestoneNumber) {
        if (milestoneNumber > 0) {
            require(milestoneContract.checkMilestoneStatus(serviceNumber, milestoneNumber -1, 5), "Milestone has not been verified by Service Requester yet.");
        }
        _;
    }

    modifier allMilestonesApproved(uint256 serviceNumber){
        require(milestoneContract.checkMinMilestoneCreated(serviceNumber), "Ensure that at least one milestone is created");
        require(milestoneContract.checkAllMilestoneApproved(serviceNumber), "All milestones must be approved first!");
        _;
    }

    modifier allMilestonesComplete(uint256 serviceNumber){
        require(milestoneContract.checkAllMilestoneCompleted(serviceNumber), "All milestones must be completed first!");
        _;
    }

    modifier allMilestonesVerified(uint256 serviceNumber){
        require(milestoneContract.checkAllMilestoneVerified(serviceNumber), "All milestones must be verified first!");
        _;
    }
    
/*
    
*/

    // Creation of service , defaults at 1 milestone. To add more milestones, use AddMilestones function
    // Project Owner, aka, Service Requester request Services for the Project
    function requestService(string memory title, string memory description, uint256 price) public requiredString(title) requiredString(description) returns (uint256) {        
        require(price > 0, "A Service Price must be specified");

        service storage newService = services[numService];
        newService.title = title;
        newService.description = description;
        newService.price = price;
        newService.serviceNumber = numService;
        newService.serviceProvider = msg.sender;
        newService.exist = true;
        newService.status = Status.none;

        emit serviceCreated(numService, newService);
        numService++;
        
        return numService;
    }

    // Deletion of service (soft deletion)
    function deleteService(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber)             /// Only Service Providers can approve service request 
            activeService(serviceNumber)                   /// Only existing services can be deleted
            hasServiceStatus(serviceNumber, Status.none)   /// Only Services that are  None can be deleted
        {
        services[serviceNumber].exist = false;
        emit serviceDeleted(serviceNumber);
    }


/*
    Service Provider Milestone Functions
*/
    // Adding milestone
    function addMilestone (uint256 serviceNumber, string memory milestoneTitle, string memory milestoneDescription ) public 
            onlyServiceProvider(serviceNumber)                             /// Only Service Providers can add milestone
            hasServiceStatusBeforeStarted(serviceNumber)                   /// Only Services that are not started yet can have milestones added
            requiredString(milestoneTitle)                                 /// Milestone Title can  not be empty.
            requiredString(milestoneDescription)                           /// Milestone Description cannot be empty.
        {
        milestoneContract.createMilestone(serviceNumber, milestoneTitle, milestoneDescription);
    }

    // Updating milestone
    function updateMilestone (uint256 serviceNumber, uint256 milestoneNumber, string memory milestoneTitle, string memory milestoneDescription ) public 
            onlyServiceProvider(serviceNumber)                             /// Only Service Providers can add milestone
            hasServiceStatusBeforeStarted(serviceNumber)                   /// Only Services that are not started yet can have milestones added
            hasMilestoneStatus(serviceNumber, milestoneNumber, Status.pending)  /// Only milestones that are pending can be deleted
            requiredString(milestoneTitle)                                 /// Milestone Title can  not be empty.
            requiredString(milestoneDescription)                           /// Milestone Description cannot be empty.
        {
        milestoneContract.updateMilestone(serviceNumber, milestoneNumber, milestoneTitle, milestoneDescription);
    }

    // Deleting milestone 
    function deleteMilestone (uint256 serviceNumber, uint256 milestoneNumber) public 
            onlyServiceProvider(serviceNumber)                                  /// Only Service Providers can delete milestone
            hasServiceStatusBeforeStarted(serviceNumber)                        /// Only Services that are not started yet can have milestones added
            hasMilestoneStatus(serviceNumber, milestoneNumber, Status.pending)  /// Only milestones that are pending can be deleted
        {        
        milestoneContract.deleteMilestone(serviceNumber, milestoneNumber);
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



/*
    Service Provider Acceptance Functions
*/    

    // Assigning Service to Project (Each service can only have 1 project, while a project can engage in multiple services)
    function assignToProject(uint256 serviceid, uint256 projectid) public {
        projectContract.addService(serviceid, projectid);
    }


    // Approving pending service request done by Service Provider 
    function approveServiceRequest(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber)              /// Only Service Providers can approve service request
            activeService(serviceNumber)                    /// Only existing services can be approved
            hasServiceStatus(serviceNumber, Status.pending) /// Only Services that are Pending can be approved
        {    
        
        assignToProject(serviceNumber, services[serviceNumber].projectid);

        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.approved;   // Changing state to accepted
        emit serviceStatusChanged(serviceNumber, before, Status.approved);
    }

    // Rejecting pending service request done by Service Provider
    function rejectServiceRequest(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber)              /// Only Service Providers can Reject Service Request
            activeService(serviceNumber)                    /// Only existing services can be rejected
            hasServiceStatus(serviceNumber, Status.pending) /// Only Services that are Pending can be Rejected
        {                
        // Change the serviceRequester back to none
        services[serviceNumber].serviceRequester = address(0);        
        services[serviceNumber].projectid = 0;

        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.none; // reverting back to original status state
        emit serviceStatusChanged(serviceNumber, before, Status.none);
    }

    // Starting the requested service done by Service Provider only if all milestones are approved and service is approved
    function startRequestedService(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber)               /// Only Service Provider can Start Service            
            activeService(serviceNumber)                     /// Only existing services can be started
            hasServiceStatus(serviceNumber, Status.approved) /// Only Services that are Approved can be Started
            allMilestonesApproved(serviceNumber)             /// Service can only be approved once all milestones are approved and at least 1 milestone is created
        {            
        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.started;
        emit serviceStatusChanged(serviceNumber, before, Status.started);

        // Find the first milestone and change the status to started
        milestoneContract.updateMilestoneStarted(serviceNumber, services[serviceNumber].currentMilestone);
    }


    // Completion of Milestone done by Service Provider
    function completeCurrMilestone(uint256 serviceNumber) public 
            onlyServiceProvider(serviceNumber)                                 /// Only Service Providers can Complete Milestone
            hasServiceStatus(serviceNumber, Status.started)                    /// Only Services that have Started can Complete Milestone
            hasMileStoneStatusVerified(serviceNumber, services[serviceNumber].currentMilestone) /// Only if previous milestone is verified then can complete next milestone
            hasMilestoneStatus(serviceNumber, services[serviceNumber].currentMilestone, Status.started) /// Only Milestones that have Started can be Completed
        {  
        milestoneContract.updateMilestoneCompleted(serviceNumber, services[serviceNumber].currentMilestone);
        // wait for milestone to be verified before completing next milestone
    }

    // Only Services that have been started can be completed and only if all milestones are verified
    function completeService(uint256 serviceNumber) public 
            onlyServiceRequester(serviceNumber)              /// Only Service Providers can Complete Service
            hasServiceStatus(serviceNumber, Status.started) /// Only Services that have Started can Complete
            allMilestonesVerified(serviceNumber)            /// Service can only be completed once all milestones are completed
        {
        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.completed;
        emit serviceStatusChanged(serviceNumber, before, Status.completed);
    }



/*
    Service Requester Pre Start Functions
*/
    // Service requester requesting service. Service must have a status of none
    // function requestService (uint256 serviceNumber, uint256 projectid) public 
    //         onlyNonServiceProvider(serviceNumber)                 /// Only Service Requesters can request for service
    //         hasServiceStatus(serviceNumber, Status.none)        /// Only Services that are newly created can be requested. i.e not approved by any other provider.           
    //         activeService(serviceNumber)                        /// Only existing services can be requested
    //     {
    //     require(services[serviceNumber].serviceRequester == address(0), "This service has been requested by another user.");   
    //     require(projectContract.getRequester(projectid) == msg.sender, "You are not authorised to assign services to this project as you are not the requester");

    //     // Change the serviceRequester to the sender
    //     services[serviceNumber].serviceRequester = msg.sender;
    //     services[serviceNumber].projectid = projectid;

    //     //  Change the service status to pending
    //     Status before = services[serviceNumber].status;
    //     services[serviceNumber].status = Status.pending; // signify pending service request
    //     emit serviceStatusChanged(serviceNumber, before, Status.pending);
    // }

    // Service requester cancelling service request. 
    // Only pending statuses can be cancelled this way. If approved, started, completed, will have dispute.
    // All if any milestones will revert back to pending
    function cancelRequestService (uint256 serviceNumber) public 
            onlyServiceRequester(serviceNumber)                 /// Only Service Requesters can cancel Request Service
            hasServiceStatus(serviceNumber, Status.pending)     /// Only Services that are Pending can be Cancelled                       
            activeService(serviceNumber)                        /// Only existing services can be cancelled
        {
        milestoneContract.updateAllMilestonePending(serviceNumber);

        services[serviceNumber].serviceRequester = address(0);
        Status before = services[serviceNumber].status;
        services[serviceNumber].status = Status.none; // reverting back to original status state
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
        milestoneContract.updateMilestoneApproved(serviceNumber, milestoneNumber);
    }




/*
    Service Requester Post Start Functions
*/
    // Verify milestone marked completed by Service Provider
    function verifyMilestone(uint256 serviceNumber, uint256 milestoneNumber) public 
            onlyServiceRequester(serviceNumber)                             /// Only Service Requesters can verify milestone
            hasMilestoneStatusCompleted(serviceNumber, milestoneNumber)     /// Only completed milestones can be verified
        {

        milestoneContract.updateMilestoneVerified(serviceNumber, milestoneNumber);
        
        if(getAllMilestonesVerified(serviceNumber)){
            // complete service if all milestones are verified
            completeService(serviceNumber);
        } else {
            // Start the next milestone
            services[serviceNumber].currentMilestone++;
            milestoneContract.updateMilestoneStarted(serviceNumber, services[serviceNumber].currentMilestone);
        }

    }

        // Service requester can raise conflict on milestone
    function rejectMilestone(uint256 serviceNumber, uint256 milestoneNumber) public
        onlyServiceRequester(serviceNumber)
        hasMilestoneStatusCompleted(serviceNumber, milestoneNumber)
        {
            conflictContract.createConflict(services[serviceNumber].projectid, serviceNumber, milestoneNumber, services[serviceNumber].serviceProvider, projectContract.getNumProviders(services[serviceNumber].projectid) - 1);
            milestoneContract.updateMilestoneConflict(serviceNumber, milestoneNumber);

            services[serviceNumber].status = Status.conflict;
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
    
    // Getter to check if all milestones have been completed.
    function getAllMilestonesVerified(uint256 serviceNumber) public view returns (bool){
        return milestoneContract.checkAllMilestoneVerified(serviceNumber);
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

    // Check if Service status is completed
    function isServiceStatusCompleted(uint256 serviceNumber) public view returns (bool) {
        return services[serviceNumber].status == Status.completed;
    }

    // Getter for current milestone
    function getCurrentMilestone(uint256 serviceNumber) public view returns (uint256){
        return services[serviceNumber].currentMilestone;
    }

    // Getter for current milestone status
    function getCurrentMilestoneStatus(uint256 serviceNumber) public view returns (Milestones.Status){
        return milestoneContract.getMilestoneStatus(serviceNumber, getCurrentMilestone(serviceNumber));
    }
}
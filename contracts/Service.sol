// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Milestone.sol";
import "./States.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

/*
    1. Service Requester (Project Owner)
    2. Service Providers (Stakeholders)
    Each Service contains milestone(s)
    Each Service can be reviewed
    Each Milestone allows conflict(s) to be raised by the service requester.
*/
contract Service {
    Milestone milestone;

    constructor (Milestone milestoneContract) public {
        milestone = milestoneContract;
    }

    struct service {
        uint256 projectNumber;
        uint256 serviceNumber;
        string title;
        string description;
        uint256 price;
        uint256 currentMilestone; // Defaults to 0 milestone
        address payable serviceRequester; // msg.sender
        address payable serviceProvider; // defaults to address(0)
        bool exist; // allowing update such as soft delete of service
        States.ServiceStatus status; // Defaults at none
    }

/*
    Events - Service Requester (Project Owner)
*/
    event serviceCreated(uint256 projectNumber, uint256 serviceNumber, string title, string description, uint256 price);
    event serviceUpdated(uint256 projectNumber, uint256 serviceNumber, string title, string description, uint256 price);
    event serviceDeleted(uint256 projectNumber, uint256 serviceNumber);


    uint256 public serviceTotal = 0; // Counts of number of services existing , only true exist bool
    uint256 public serviceNum = 0; // Project Number/ID , value only goes up, includes both true and false exist bool
    mapping (uint256 => mapping (uint256 => service)) public projectServices; // [projectNumber][serviceNumber] 


/*
    Modifiers
*/

    modifier requiredString(string memory str) {
        require(bytes(str).length > 0, "A string is required!");
        _;
    }

    modifier onlyServiceRequester(uint256 projectNumber, uint256 serviceNumber, address serviceRequester){ // Only allow Service Requester / Project Owner can access these functions
        require(serviceRequester == projectServices[projectNumber][serviceNumber].serviceRequester, "Unauthorised access to service, only service requester can access");
        _;
    }

    modifier onlyServiceProvider(uint256 projectNumber, uint256 serviceNumber, address serviceProvider){ // Only allow Service serviceProvider / Project Owner can access these functions
        require(serviceProvider == projectServices[projectNumber][serviceNumber].serviceProvider, "Unauthorised access to service, only service serviceProvider can access");
        _;
    }

    modifier activeService(uint256 projectNumber, uint256 serviceNumber) {
        require(projectServices[projectNumber][serviceNumber].exist == true, "This service has been deleted and does not exist anymore");
        _;
    }

    modifier atState(uint256 projectNumber, uint256 serviceNumber, States.ServiceStatus state) {
        require(projectServices[projectNumber][serviceNumber].status == state, "The status of this service does not match the intended status.");
        _;
    }

/*
    Setter Functions
*/

    function setState(uint256 projectNumber, uint256 serviceNumber, States.ServiceStatus state) internal {
        projectServices[projectNumber][serviceNumber].status = state;
    }

/*
    Service Requester (Project Owner) Functions
*/

    /*
        Service - Create
    */

    function createService(uint256 projectNumber, string memory title, string memory description, uint256 price, address payable projectOwner) external 
        requiredString(title) 
        requiredString(description) 
    {        
        require(price > 0, "A Service Price must be specified");

        service storage newService = projectServices[projectNumber][serviceNum];
        newService.projectNumber = projectNumber;
        newService.serviceNumber = serviceNum;
        newService.title = title;
        newService.description = description;
        newService.price = price;
        newService.currentMilestone = 0;
        newService.serviceRequester = projectOwner;
        newService.serviceProvider = payable(address(0));
        newService.exist = true;
        newService.status = States.ServiceStatus.created;

        emit serviceCreated(projectNumber, serviceNum, title, description, price);

        serviceTotal++;
        serviceNum++;
    }

    /*
        Service - Read 
    */

    function readServiceTitle(uint256 projectNumber, uint256 serviceNumber) external view 
        activeService(projectNumber, serviceNumber)
    returns (string memory) {
        return projectServices[projectNumber][serviceNumber].title;
    }

    /*
        Service - Update
    */

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price) external 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.created)
        requiredString(title)
        requiredString(description)
    {
        // need to set a requirement for onlyServiceRequester?
        require(price > 0, "A Service Price must be specified");
        projectServices[projectNumber][serviceNumber].title = title;
        projectServices[projectNumber][serviceNumber].description = description;
        projectServices[projectNumber][serviceNumber].price = price;

        emit serviceUpdated(projectNumber, serviceNumber, title, description, price);
    }

    /*
        Service - Delete
    */

    function deleteService(uint256 projectNumber, uint256 serviceNumber) external 
        onlyServiceProvider(projectNumber, serviceNumber, msg.sender)
        activeService(projectNumber, serviceNumber)
    {
        projectServices[projectNumber][serviceNumber].exist = false;
        serviceTotal--;
        setState(projectNumber, serviceNumber, States.ServiceStatus.terminated);

        emit serviceDeleted(projectNumber,serviceNumber);
    }

    /*
        Service - Accept service request  
        Function for project owner to accept a contractor's service 
    */

    function acceptServiceRequest(uint256 projectNumber, uint256 serviceNumber, address serviceRequester, address serviceProvider) external 
        onlyServiceRequester(projectNumber,serviceNumber,serviceRequester) 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.pending)
    {
        setState(projectNumber, serviceNumber, States.ServiceStatus.accepted);  
        projectServices[projectNumber][serviceNumber].serviceProvider = payable(serviceProvider);  
    }

    /*
        Service - Reject service request  
        Function for project owner to reject a contractor's service 
    */

    function rejectServiceRequest(uint256 projectNumber, uint256 serviceNumber, address serviceRequester) external 
        onlyServiceRequester(projectNumber,serviceNumber,serviceRequester) 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.pending)
    {
        setState(projectNumber, serviceNumber, States.ServiceStatus.created);
        projectServices[projectNumber][serviceNumber].serviceProvider = payable(address(0));
    }

    // /*
    //     Service - Raise Conflict
    //     Function for project owner to reject a contractor's service 
    // */

    // function raiseConflict(uint256 projectNumber, uint256 serviceNumber, address serviceRequester) external 
    //     onlyServiceRequester(projectNumber,serviceNumber,serviceRequester) {
    //         projectServices[projectNumber][serviceNumber].status = States.ServiceStatus.none;
    //         projectServices[projectNumber][serviceNumber].serviceProvider = payable(address(0));
    // }

    /*
        Milestone - Create
    */
    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone) external 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.created)
    {
        milestone.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Read
    */   
    function readMilestoneTitle(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external view 
        activeService(projectNumber, serviceNumber)
    returns (string memory) {
        return milestone.readMilestoneTitle(projectNumber,serviceNumber,milestoneNumber);
    }
    
    /*
        Milestone - Update
    */
    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory titleMilestone, string memory descriptionMilestone) external 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.created)
    {
        // need to set a requirement for onlyServiceRequester?
        milestone.updateMilestone(projectNumber,serviceNumber,milestoneNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Delete
    */
    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.created)
    {        
        milestone.deleteMilestone(projectNumber,serviceNumber,milestoneNumber);
    }

    /*
        Milestone - Complete 
    */
    function completeMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.created)
    {
        // To report the completion of the milestone
        milestone.completeMilestone(projectNumber, serviceNumber, milestoneNumber);
    }

    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description, address serviceRequester,  uint256 totalVoters) external 
        onlyServiceRequester(projectNumber,serviceNumber,serviceRequester)
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.accepted)
        requiredString(title)
        requiredString(description)

    {
        address serviceProvider = projectServices[projectNumber][serviceNumber].serviceProvider;
        milestone.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,serviceRequester,serviceProvider,totalVoters);
        setState(projectNumber, serviceNumber, States.ServiceStatus.conflict);
    }

    /*
        Conflict - Update
    */

    function updateConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.conflict)
        requiredString(title)
        requiredString(description)
    {
        // need to set a requirement for onlyServiceRequester?
        milestone.updateConflict(projectNumber,serviceNumber,milestoneNumber,title,description);
    }

    /*
        Conflict - Delete
    */ 

    function deleteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.conflict)
    {
        milestone.deleteConflict(projectNumber,serviceNumber,milestoneNumber);  
    }

    /*
        Conflict - Vote
    */
    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address sender, uint8 vote) external 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.conflict)
    {
        // Need to set a requirement that only voters working on the same project can vote?
        milestone.voteConflict(projectNumber,serviceNumber,milestoneNumber,sender,vote);
    }

/*
    Service provider Functions
*/

    /*
        Service - Update state 
    */

    function takeServiceRequest(uint256 projectNumber, uint256 serviceNumber, address serviceProvider) public 
        onlyServiceProvider(projectNumber, serviceNumber, serviceProvider)
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.created)
    {
        require(projectServices[projectNumber][serviceNumber].serviceProvider == address(0), "This Service is already taken!");
        //service storage requestedService = projectServices[projectNumber][serviceNumber]; 
        //check if service is open for work 
        //require(requestedService.status == States.ServiceStatus.created, "You are currently not allowed to work on this service"); 
        //change service status to pending for project owner approval  
        setState(projectNumber, serviceNumber, States.ServiceStatus.pending);
        //requestedService.serviceProvider = payable(serviceProvider); 
    }

    /*
        Service - Complete service request
    */

    function completeServiceRequest(uint256 projectNumber, uint256 serviceNumber, address serviceProvider) external 
        onlyServiceProvider(projectNumber,serviceNumber,serviceProvider) 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.accepted)
    {
        require(projectServices[projectNumber][serviceNumber].serviceProvider == serviceProvider, "You are not working on this Service!");
        setState(projectNumber, serviceNumber, States.ServiceStatus.completed);
    }

}
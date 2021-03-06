// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Milestone.sol";
import "./States.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./SafeMath.sol";

/*
    1. Service Requester (Project Owner)
    2. Service Providers (Stakeholders)
    Each Service contains milestone(s)
    Each Service can be reviewed
    Each Milestone allows conflict(s) to be raised by the service requester.
*/
contract Service {
    
    using SafeMath for uint256;
    
    Milestone milestone;


    constructor (Milestone milestoneContract) public {
        milestone = milestoneContract;
    }

    struct service {
        uint256 projectNumber;
        uint256 serviceNumber;
        string title;
        string description;
        address  serviceRequester; // msg.sender
        address  serviceProvider; // defaults to address(0)
        bool exist; // allowing update such as soft delete of service
        States.ServiceStatus status; // Defaults at none
        uint256 numMilestones;
    }

/*
    Events - Service Requester (Project Owner)
*/
    event serviceCreated(uint256 projectNumber, uint256 serviceNumber, string title, string description);
    event serviceUpdated(uint256 projectNumber, uint256 serviceNumber, string title, string description);
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

    modifier onlyServiceRequester(uint256 projectNumber, uint256 serviceNumber, address serviceRequester) { // Only allow Service Requester / Project Owner can access these functions
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

    function getState(uint256 projectNumber, uint256 serviceNumber) public view returns (uint) {
        return uint(projectServices[projectNumber][serviceNumber].status);
    }

/*
    Service functions
*/

    /*
        Service - Create
    */

    function createService(uint256 projectNumber, string memory title, string memory description, address  projectOwner) external 
        requiredString(title) 
        requiredString(description) 
    {        

        service storage newService = projectServices[projectNumber][serviceNum];
        newService.projectNumber = projectNumber;
        newService.serviceNumber = serviceNum;
        newService.title = title;
        newService.description = description;
        newService.serviceRequester = projectOwner;
        newService.serviceProvider = address(0);
        newService.exist = true;
        newService.status = States.ServiceStatus.created;
        newService.numMilestones = 0;

        emit serviceCreated(projectNumber, serviceNum, title, description);

        serviceTotal++;
        serviceNum++;
    }

    /*
        Service - Update
    */

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, address  _from) external 
        onlyServiceRequester(projectNumber, serviceNumber, _from)
        activeService(projectNumber, serviceNumber)
        requiredString(title)
        requiredString(description)
    {
        // need to set a requirement for onlyServiceRequester?
   
        projectServices[projectNumber][serviceNumber].title = title;
        projectServices[projectNumber][serviceNumber].description = description;

        emit serviceUpdated(projectNumber, serviceNumber, title, description);
    }

    /*
        Service - Delete
    */

    function deleteService(uint256 projectNumber, uint256 serviceNumber, address  _from) external 
        onlyServiceRequester(projectNumber, serviceNumber,_from)
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

    function acceptServiceRequest(uint256 projectNumber, uint256 serviceNumber, address _from) external 
        onlyServiceRequester(projectNumber,serviceNumber,_from) 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.pending)
    {
        setState(projectNumber, serviceNumber, States.ServiceStatus.accepted);
        address provider = projectServices[projectNumber][serviceNumber].serviceProvider;
        milestone.acceptMilestone(projectNumber, serviceNumber,provider);
    }

    /*
        Service - Reject service request  
        Function for project owner to reject a contractor's service 
    */

    function rejectServiceRequest(uint256 projectNumber, uint256 serviceNumber, address  _from) external 
        onlyServiceRequester(projectNumber,serviceNumber,_from) 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.pending)
    {
        setState(projectNumber, serviceNumber, States.ServiceStatus.created);
        projectServices[projectNumber][serviceNumber].serviceProvider = address(0);
    }

    /*
        Service - Request to start service
    */

    function takeServiceRequest(uint256 projectNumber, uint256 serviceNumber, address _from) public 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.created)
    {
        require(projectServices[projectNumber][serviceNumber].serviceProvider == address(0), "This Service is already taken!");
        require(projectServices[projectNumber][serviceNumber].serviceRequester != _from, "You cannot work on your own project");
        setState(projectNumber, serviceNumber, States.ServiceStatus.pending);
        projectServices[projectNumber][serviceNumber].serviceProvider = _from;
    }

    /*
        Service - Complete service request
    */

    function completeServiceRequest(uint256 projectNumber, uint256 serviceNumber, address  _from) external 
        onlyServiceProvider(projectNumber,serviceNumber,_from) 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.accepted)
    {
        require(projectServices[projectNumber][serviceNumber].serviceProvider == _from, "You are not working on this Service!");
        setState(projectNumber, serviceNumber, States.ServiceStatus.completed);
    }


    function getServiceTitle(uint256 projectNumber, uint256 serviceNumber) public view returns(string memory) {
        return projectServices[projectNumber][serviceNumber].title;
    }

    function getServiceDescription(uint256 projectNumber, uint256 serviceNumber) public view returns(string memory) {
        return projectServices[projectNumber][serviceNumber].description;
    }   

    function getServiceProvider(uint256 projectNumber, uint256 serviceNumber) public view returns(address) {
        return projectServices[projectNumber][serviceNumber].serviceProvider;
    }   

/*

    Milestone functions

*/

    /*
        Milestone - Create
    */
    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone, uint256 price, address  _from) external 
        onlyServiceRequester(projectNumber, serviceNumber,_from)
        activeService(projectNumber, serviceNumber)
        // atState(projectNumber, serviceNumber, States.ServiceStatus.created)
    {
        milestone.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone, price, _from);
        projectServices[projectNumber][serviceNumber].numMilestones += 1;
    }
    
    /*
        Milestone - Update
    */
    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory titleMilestone, string memory descriptionMilestone, address  _from) external 
        onlyServiceRequester(projectNumber, serviceNumber,_from)
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.created)
    {
        // need to set a requirement for onlyServiceRequester?
        milestone.updateMilestone(projectNumber,serviceNumber,milestoneNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Delete
    */
    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber,address  _from) external 
        onlyServiceRequester(projectNumber, serviceNumber,_from)
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.created)
    {        
        milestone.deleteMilestone(projectNumber,serviceNumber,milestoneNumber);
        projectServices[projectNumber][serviceNumber].numMilestones -= 1;
    }

    /*
        Milestone - Complete 
    */
    function completeMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address  _from) external 
        onlyServiceProvider(projectNumber, serviceNumber,_from)
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.accepted)
    {
        // To report the completion of the milestone
        milestone.completeMilestone(projectNumber, serviceNumber, milestoneNumber);
    }

    // /*
    //     Milestone - make milestone payment 
    // */

    // function makeMilestonePayment(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external 
    //     activeService(projectNumber, serviceNumber)
    //     atState(projectNumber, serviceNumber, States.ServiceStatus.accepted)
    // {
    //     // To report the completion of the milestone
    //     milestone.makeMilestonePayment(projectNumber, serviceNumber, milestoneNumber);
    // }

    /*
        Milestone - Verify 
    */

    function verifyMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from) external 
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.accepted)
    {
        address requester = projectServices[projectNumber][serviceNumber].serviceRequester;
        require(_from == requester, "You are not the requester of this service. You cannot verify.");
        // To report the completion of the milestone
        milestone.verifyMilestone(projectNumber, serviceNumber, milestoneNumber);
    }


    /*
        Milestone - review 
    */

    function reviewMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address  _from, string memory review_input, uint star_rating) public {
        milestone.reviewMilestone(projectNumber,serviceNumber,milestoneNumber,_from,review_input,star_rating);
    }

/*

    Conflict Functions

*/

    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description, address _from,  uint256 totalVoters) external 
        // onlyServiceRequester(projectNumber,serviceNumber,serviceRequester) //REMOVED FOR STACK ERROR
        // activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.accepted)
        requiredString(title)
        requiredString(description)

    {
        address requester = projectServices[projectNumber][serviceNumber].serviceRequester;
        require(_from == requester, "You are not the requester of this service. You cannot create conflict.");

        milestone.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,totalVoters);
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
        Conflict - Start Vote
    */

    function startVote(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address  _from) external
        activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.conflict)
    {
        milestone.startVote(projectNumber, serviceNumber, milestoneNumber, projectServices[projectNumber][serviceNumber].numMilestones, _from);
    }

    /*
        Conflict - Vote
    */
    
    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from, uint8 vote) external 
        // activeService(projectNumber, serviceNumber)
        atState(projectNumber, serviceNumber, States.ServiceStatus.conflict)
    {
        milestone.voteConflict(projectNumber,serviceNumber,milestoneNumber,projectServices[projectNumber][serviceNumber].numMilestones,_from,vote);
    }

    // /*
    //     Conflict - Resolve conflict payment 
    // */
    function resolveConflictPayment(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        milestone.resolveConflictPayment( projectNumber,  serviceNumber,  milestoneNumber);
        setState(projectNumber, serviceNumber, States.ServiceStatus.accepted);
    }


    // Star Rating getters
    function getAvgServiceProviderStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        return milestone.getAvgServiceProviderStarRating(projectNumber,serviceNumber);
    }

    // Star Rating getters
    function getAvgServiceRequesterStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        return milestone.getAvgServiceRequesterStarRating(projectNumber,serviceNumber);
    }

    // Get Service Requester
    function getServiceRequester(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (address) {
        return projectServices[projectNumber][serviceNumber].serviceRequester;
    }

    // Get Service Provider
    function getServiceProvider(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (address) {
        return projectServices[projectNumber][serviceNumber].serviceProvider;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Service.sol";
import "./States.sol";
import "./Profile.sol";

/*
    Service Requester (Project Owner)
*/
contract Project {
    
    Service service; 
    Profile profile; 

    constructor(Service serviceContract, Profile profileContract) public {
        service = serviceContract;
        profile = profileContract;
    }
    

    struct project {
        uint256 projectNumber; 
        string title;
        string description;
        address projectOwner; // defaults to address(0) , service requester
        bool exist; // allowing update such as soft delete of project - projectNum
        States.ProjectStatus projectstatus;
    }

    uint256 public projectTotal = 0; // Counts of number of projects existing , only true exist bool
    uint256 public projectNum = 0; // Project Number/ID , value only goes up, includes both true and false exist bool
    mapping(uint256 => project) public projects;

    event projectCreated(uint256 projectNumber, string title, string description, address projectOwner);
    event projectUpdated(uint256 projectNumber, string title, string description, address projectOwner);
    event projectDeleted(uint256 projectNumber, address projectOwner);

/*
    Modifiers
*/
    modifier checkValidProject(uint256 projectNumber) {
        require(projects[projectNumber].exist, "This project has not been created yet. Please create project first");
        require(projects[projectNumber].projectstatus == States.ProjectStatus.active, "This project is no longer active.");
        _;
    }

    modifier onlyOwner(uint256 projectNumber, address user) {
        require (projects[projectNumber].projectOwner == user, "You are not authorized to edit this project as you are not the creator");
        _;
    }

    modifier atState(uint256 projectNumber, States.ProjectStatus state){
        require(projects[projectNumber].projectstatus == state, "Cannot carry out this operation!");
        _;
    }


/*
    Project Owner Functions
*/

    /*
        Project - Create 
    */
    
    function createProject(string memory title, string memory description) public {
                
        project storage newProject = projects[projectNum];
        newProject.projectNumber = projectNum;
        newProject.title = title;
        newProject.description = description;
        newProject.projectOwner = msg.sender;
        newProject.exist = true;
        newProject.projectstatus = States.ProjectStatus.active;

        emit projectCreated(projectNum, title, description, msg.sender);
        projectTotal++;
        projectNum++;
    }

    /*
        Project - Read 
    */

    function readProjectTitle(uint256 projectNumber) public view 
        checkValidProject(projectNumber)
        atState(projectNumber, States.ProjectStatus.active)
    returns (string memory)  {
        return projects[projectNumber].title;
    }

    /*
        Project - Update (only in active state)
    */
    
    function updateProject(uint256 projectNumber, string memory title, string memory description) public 
        checkValidProject(projectNumber)
        onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        projects[projectNumber].title = title;
        projects[projectNumber].description = description;

        emit projectUpdated(projectNumber, title, description, msg.sender);
    }

    /*
        Project - Delete (only in active state)
    */
    function deleteProject(uint256 projectNumber) public 
        checkValidProject(projectNumber)
        onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {

        projects[projectNumber].exist = false;

        projectTotal --;
        setState(projectNumber, States.ProjectStatus.inactive);
        emit projectDeleted(projectNumber, msg.sender);
    }

    
    /*
        Project - Complete
        Can add payment functions here 
    */
    
    // function completeProject(uint256 projectNumber) public onlyOwner(projectNumber,msg.sender) {

    // }



    /*
        Service - Create
    */

    function createService(uint256 projectNumber, string memory title, string memory description, uint256 price) public 
        onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.createService(projectNumber,title,description,price,payable(msg.sender));
    }

    /*
        Service - Read
    */

    function readServiceTitle(uint256 projectNumber, uint256 serviceNumber) public view 
        atState(projectNumber, States.ProjectStatus.active)
    returns (string memory){
        service.readServiceTitle(projectNumber,serviceNumber);
    }

    /*
        Service - Update
    */

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price, States.ServiceStatus status) public 
        onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.updateService(projectNumber,serviceNumber,title,description,price,status);
    }

    /*
        Service - Delete
    */

    function deleteService(uint256 projectNumber, uint256 serviceNumber) public 
        onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.deleteService(projectNumber,serviceNumber);
    }

    /*
        Service - Accept service request  
        Function for project owner to accept a contractor's service 
    */

    function acceptServiceRequest(uint256 projectNumber, uint256 serviceNumber, address serviceRequester) external 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.acceptServiceRequest(projectNumber,serviceNumber,serviceRequester);
    }

    /*
        Service - Reject service request  
        Function for project owner to reject a contractor's service 
    */

    function rejectServiceRequest(uint256 projectNumber, uint256 serviceNumber, address serviceRequester) external 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.rejectServiceRequest(projectNumber,serviceNumber,serviceRequester);   
    }

    /*
        Milestone - Create
    */

    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone) public 
        onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Read
    */   

    function readMilestoneTitle(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view 
        atState(projectNumber, States.ProjectStatus.active)
    returns (string memory) {
        service.readMilestoneTitle(projectNumber,serviceNumber,milestoneNumber);
    }

    /*
        Milestone - Update
    */

    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory titleMilestone, string memory descriptionMilestone) public 
        onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.updateMilestone(projectNumber,serviceNumber,milestoneNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Delete
    */ 

    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public 
        onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.deleteMilestone(projectNumber,serviceNumber,milestoneNumber);
    }    

    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description, address serviceRequester, uint256 totalVoters) external
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,serviceRequester,totalVoters);
    }

    /*
        Conflict - Update
    */

    function updateConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.updateConflict(projectNumber,serviceNumber,milestoneNumber,title,description);
    }

    /*
        Conflict - Delete
    */ 

    function deleteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external  
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.deleteConflict(projectNumber,serviceNumber,milestoneNumber);  
    }

    /*
        Conflict - Vote
    */

    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address sender, uint8 vote) external 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.voteConflict(projectNumber,serviceNumber,milestoneNumber,sender,vote);
    }

/*
    Getter Helper Functions
*/

    function getProjectOwner(uint256 projectId) public view returns(address) {
        projects[projectId].projectOwner;
    }

/*
    Setter Functions
*/

    function setState(uint256 projectId, States.ProjectStatus state) internal {
        projects[projectId].projectstatus = state;
    }

/*
    Service provider Functions
*/

    /*
        Service - Request to start service 
        Function for contractor to request to start a service 
    */
    
    function takeServiceRequest(uint256 projectNumber, uint256 serviceNumber, address serviceProvider) public  
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.takeServiceRequest(projectNumber, serviceNumber, serviceProvider); 
    }

    /*
        Service - Complete service request
    */

    function completeServiceRequest(uint256 projectNumber, uint256 serviceNumber, address serviceProvider) external  
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.completeServiceRequest(projectNumber, serviceNumber, serviceProvider);      
    }



}
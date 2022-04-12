// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Service.sol";
import "./States.sol";

/*
    Service Requester (Project Owner)
*/
contract Project {
    
    Service service; 

    constructor(Service serviceContract) public {
        service = serviceContract;
    }
    

    struct project {
        uint256 projectNumber; 
        string title;
        string description;
        address projectOwner; // defaults to address(0) , service requester
        bool exist; // allowing update such as soft delete of project - projectNum
        int num_providers; // keeping track of the number of accepted Service Providers  (increment when service is accepted)
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
    
    function createProject(string memory title, string memory description, address _from) public {
                
        project storage newProject = projects[projectNum];
        newProject.projectNumber = projectNum;
        newProject.title = title;
        newProject.description = description;
        newProject.projectOwner =_from;
        newProject.exist = true;
        newProject.num_providers = 0;
        newProject.projectstatus = States.ProjectStatus.active;

        emit projectCreated(projectNum, title, description, _from);
        projectTotal++;
        projectNum++;
    }

    /*
        Project - Update (only in active state)
    */
    
    function updateProject(uint256 projectNumber, string memory title, string memory description, address _from ) public 
        checkValidProject(projectNumber)
        onlyOwner(projectNumber,_from) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        projects[projectNumber].title = title;
        projects[projectNumber].description = description;

        emit projectUpdated(projectNumber, title, description, _from);
    }

    /*
        Project - Delete (only in active state)
    */
    function deleteProject(uint256 projectNumber , address _from) public 
        checkValidProject(projectNumber)
        onlyOwner(projectNumber, _from) 
        atState(projectNumber, States.ProjectStatus.active)
    {

        projects[projectNumber].exist = false;

        projectTotal --;
        setState(projectNumber, States.ProjectStatus.inactive);
        emit projectDeleted(projectNumber, _from);
    }

/*
    Getter Helper Functions
*/

    function getProjectOwner(uint256 projectId) public view returns(address) {
        return projects[projectId].projectOwner;
    }

    function getProjectTitle(uint256 projectId) public view returns(string memory) {
        return projects[projectId].title;
    }

    function getProjectDescription(uint256 projectId) public view returns(string memory) {
        return projects[projectId].description;
    }

/*
    Setter Functions
*/

    function setState(uint256 projectId, States.ProjectStatus state) internal {
        projects[projectId].projectstatus = state;
    }

/*

    Service Functions

*/


    /*
        Service - Create
    */

    function createService(uint256 projectNumber, string memory title, string memory description, address _from) public 
        // onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.createService(projectNumber,title,description,payable(_from));
    }

    /*
        Service - Update
    */

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price, States.ServiceStatus status, address _from) public 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.updateService(projectNumber,serviceNumber,title,description,payable(_from));
    }

    /*
        Service - Delete
    */

    function deleteService(uint256 projectNumber, uint256 serviceNumber, address _from, ERC20 erc20) public 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.deleteService(projectNumber,serviceNumber,payable(_from),erc20);
    }

    /*
        Service - Accept service request  
        Function for service requester to accept a contractor's service 
    */

    function acceptServiceRequest(uint256 projectNumber, uint256 serviceNumber, address _from) external 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.acceptServiceRequest(projectNumber,serviceNumber,payable(_from));
        num_providers++;
    }

    /*
        Service - Request to start service 
        Function for service provider to request to start a service 
    */
    
    function takeServiceRequest(uint256 projectNumber, uint256 serviceNumber, address _from) public  
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.takeServiceRequest(projectNumber, serviceNumber, payable(_from)); 
    }

    /*
        Service - Complete service request
        function for service provider
    */

    function completeServiceRequest(uint256 projectNumber, uint256 serviceNumber, address _from) external  
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.completeServiceRequest(projectNumber, serviceNumber, payable(_from));      
    }

    /*
        Service - Reject service request  
        Function for Service requester to reject a contractor's service 
    */

    function rejectServiceRequest(uint256 projectNumber, uint256 serviceNumber, address _from) external 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.rejectServiceRequest(projectNumber,serviceNumber,payable(_from));   
    }


    function getServiceTitle(uint256 projectNumber, uint256 serviceNumber) public view returns(string memory) {
        service.getServiceTitle(projectNumber,serviceNumber);
    }

    function getServiceDescription(uint256 projectNumber, uint256 serviceNumber) public view returns(string memory) {
        service.getServiceDescription(projectNumber,serviceNumber);
    }   

/*

    Milestone functions

*/

    /*
        Milestone - Create
    */

    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone,uint256 price, address  _from) public 
        onlyOwner(projectNumber, _from) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone, price, payable(_from));
    }

    /*
        Milestone - Update
    */

    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory titleMilestone, string memory descriptionMilestone, address _from) public 
        onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.updateMilestone(projectNumber,serviceNumber,milestoneNumber,titleMilestone,descriptionMilestone, payable(_from));
    }

    /*
        Milestone - Delete
    */ 

    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from, ERC20 erc20) public 
        // onlyOwner(projectNumber,msg.sender) 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.deleteMilestone(projectNumber,serviceNumber,milestoneNumber, payable(_from), erc20);
    }    

    /*
        Milestone - Complete 
    */
    function completeMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from) external 
        atState(projectNumber, States.ProjectStatus.active)
    {
        // To report the completion of the milestone
        service.completeMilestone(projectNumber, serviceNumber, milestoneNumber, payable(_from));
    }

    /*
        Milestone - Verify 
    */
    function verifyMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from) external 
        atState(projectNumber, States.ProjectStatus.active)
    {
        // To report the completion of the milestone
        service.verifyMilestone(projectNumber, serviceNumber, milestoneNumber , _from);
    }

/*

    Conflict functions

*/


    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description, address serviceRequester) external
        atState(projectNumber, States.ProjectStatus.active)
    {
        require(projects[projectNumber].num_providers >= 0, "You have to accept a service request from a service Provider before you can create a conflict");
        service.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,payable(serviceRequester),projects[projectNumber].num_providers-1);
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
        Conflict - Start Vote
    */
    function startVote(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from) external
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.startVote(projectNumber, serviceNumber, milestoneNumber,payable(_from));
    }

    /*
        Conflict - Vote
    */

    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from, uint8 vote) external 
        atState(projectNumber, States.ProjectStatus.active)
    {
        service.voteConflict(projectNumber,serviceNumber,milestoneNumber,payable(_from),vote);
    }

/*

    Review functions

*/
 
    /*
        Review - Create
    */

    function reviewMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from, string memory review_input, uint star_rating) public {
        service.reviewMilestone(projectNumber,serviceNumber,milestoneNumber,payable(_from),review_input,star_rating);
    }

    /*
        Review - Getter Provider Stars
    */

    function getAvgServiceProviderStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        return service.getAvgServiceProviderStarRating(projectNumber,serviceNumber);
    }

    /*
        Review - Getter Requester Stars
    */

    function getAvgServiceRequesterStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        return service.getAvgServiceRequesterStarRating(projectNumber,serviceNumber);
    }

}
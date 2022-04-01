// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Service.sol";

/*
    Service Requester (Project Owner)
*/
contract Project {
    
    Service service; 

    constructor(Service serviceContract) public {
        service = serviceContract;
    }
    
    enum ProjectStatus { none, active, inactive, terminated }

    struct project {
        uint256 projectNumber; 
        string title;
        string description;
        address projectOwner; // defaults to address(0)
        bool exist; // allowing update such as soft delete of project - projectNum
        ProjectStatus projectstatus;
    }

    uint256 public projectTotal = 0; // Counts of number of projects existing , only true exist bool
    uint256 public projectNum = 0; // Project Number/ID , value only goes up, includes both true and false exist bool
    mapping(uint256 => project) projects;

    event projectCreated(uint256 projectNumber, string title, string description, address projectOwner);
    event projectUpdated(uint256 projectNumber, string title, string description, address projectOwner);
    event projectDeleted(uint256 projectNumber, address projectOwner);

/*
    Modifiers
*/
    modifier checkValidProject(uint256 projectNumber) {
        require(projects[projectNumber].exist, "This project has not been created yet. Please create project first");
        require(projects[projectNumber].projectstatus == ProjectStatus.active, "This project is no longer active.");
        _;
    }

    modifier onlyOwner(uint256 projectNumber, address user) {
        require (projects[projectNumber].projectOwner == user, "You are not authorized to edit this project as you are not the creator");
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
        newProject.projectstatus = ProjectStatus.active;

        emit projectCreated(projectNum, title, description, msg.sender);
        projectTotal++;
        projectNum++;
    }

    /*
        Project - Read 
    */

    function readProject(uint256 projectNumber) public view returns (string memory , string memory) {
        return (projects[projectNumber].title, projects[projectNumber].description);
    }

    /*
        Project - Update 
    */
    
    function updateProject(uint256 projectNumber, string memory title, string memory description) public onlyOwner(projectNumber,msg.sender) {

        projects[projectNumber].title = title;
        projects[projectNumber].description = description;

        emit projectUpdated(projectNumber, title, description, msg.sender);
    }

    /*
        Project - Delete 
    */
    
    function deleteProject(uint256 projectNumber) public onlyOwner(projectNumber,msg.sender) {

        projects[projectNumber].exist = false;

        projectTotal --;
        emit projectDeleted(projectNumber, msg.sender);
    }


    /*
        Service - Create
    */

    function createService(uint256 projectNumber, string memory title, string memory description, uint256 price) public onlyOwner(projectNumber,msg.sender) {
        service.createService(projectNumber,title,description,price);
    }

    /*
        Service - Read
    */

    function readService(uint256 projectNumber, uint256 serviceNumber) public view returns (string memory , string memory, uint256 , uint256 ) {
        service.readService(projectNumber,serviceNumber);
    }

    /*
        Service - Update
    */

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price) public onlyOwner(projectNumber,msg.sender) {
        service.updateService(projectNumber,serviceNumber,title,description,price);
    }

    /*
        Service - Delete
    */

    function deleteService(uint256 projectNumber, uint256 serviceNumber) public onlyOwner(projectNumber, msg.sender) {
        service.deleteService(projectNumber,serviceNumber);
    }

    /*
        Milestone - Create
    */

    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone) public onlyOwner(projectNumber, msg.sender) {
        service.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Read
    */   

    function readMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (string memory , string memory ) {
        service.readMilestone(projectNumber,serviceNumber,milestoneNumber);
    }

    /*
        Milestone - Update
    */

    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory titleMilestone, string memory descriptionMilestone) public onlyOwner(projectNumber, msg.sender) {
        service.updateMilestone(projectNumber,serviceNumber,milestoneNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Delete
    */ 
    
    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public onlyOwner(projectNumber, msg.sender) {
        service.deleteMilestone(projectNumber,serviceNumber,milestoneNumber);
    }    

/*
    Getter Helper Functions
*/

    function getProjectOwner(uint256 projectId) public view returns(address) {
        return projects[projectId].projectOwner;
    }

}
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
        bool exist; // allowing update such as soft delete of project
        ProjectStatus projectstatus;
    }

    uint256 public numProject;
    mapping(uint256 => project) projects;

    event projectCreated(uint256 projectid, string title, string description, address projectOwner);

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
                
        project storage newProject = projects[numProject];
        newProject.projectNumber = numProject;
        newProject.title = title;
        newProject.description = description;
        newProject.projectOwner = msg.sender;
        newProject.exist = true;
        newProject.projectstatus = ProjectStatus.active;

        emit projectCreated(numProject, title, description, msg.sender);
        numProject++; 
    }

    /*
        Service - Request
    */

    function requestService(uint256 projectNumber, string memory title, string memory description, uint256 price) public onlyOwner(projectNumber,msg.sender) {
        service.requestService(projectNumber,title,description,price);
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
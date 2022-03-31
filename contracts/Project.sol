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
        uint256 projectId; 
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
    modifier checkValidProject(uint256 projectid) {
        require(projects[projectid].exist, "This project has not been created yet. Please create project first");
        require(projects[projectid].projectstatus == ProjectStatus.active, "This project is no longer active.");
        _;
    }

    modifier onlyOwner(uint256 projectid, address user) {
        require (projects[projectid].projectOwner == user, "You are not authorized to edit this project as you are not the creator");
        _;
    }


/*
    Project Owner Functions
*/

    /*
        Create Project
    */
    
    function createProject(string memory title, string memory description) public {
                
        project storage newProject = projects[numProject];
        newProject.projectId = numProject;
        newProject.title = title;
        newProject.description = description;
        newProject.projectOwner = msg.sender;
        newProject.exist = true;
        newProject.projectstatus = ProjectStatus.active;

        emit projectCreated(numProject, title, description, msg.sender);
        numProject++; 
    }

    /*
        Request Service for Project 
    */

    function requestService(uint256 projectNumber, string memory title, string memory description, uint256 price) public onlyOwner(projectNumber,msg.sender) {
        service.requestService(projectNumber,title,description,price);
    }

    /*
        Delete Request Service for Project 
    */

    function deleteRequestService(uint256 projectNumber, uint256 serviceNumber) public onlyOwner(projectNumber, msg.sender) {
        service.deleteRequestService(projectNumber,serviceNumber);
    }



/*
    Getter Helper Functions
*/

    function getProjectOwner(uint256 projectId) public view returns(address) {
        return projects[projectId].projectOwner;
    }
    
}
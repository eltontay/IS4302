// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Service.sol";

contract Project {
    
    // Service serviceContract; 

    // constructor(Service serviceContract) public {
    //     serviceContract = serviceAddress;
    // }
    
    enum ProjectStatus { none, active, inactive, terminated }

    struct project {
        string title;
        string description;
        address serviceRequester; // defaults to address(0)
        bool exist; // allowing update such as soft delete of service
        ProjectStatus projectstatus;
        uint256[] services;
    }

    uint256 public numProject;
    mapping(uint256 => project) projects;

    event projectCreated(uint256 projectid, string title, address serviceRequester);

    modifier checkValidProject(uint256 projectid) {
        require(projects[projectid].exist, "This project has not been created yet. Please create project first");
        require(projects[projectid].projectstatus == ProjectStatus.active, "This project is no longer active, please activate it first");
        _;
    }

    modifier onlyOwner(uint256 projectid, address user) {
        require (projects[projectid].serviceRequester == user, "You are not authorized to edit this project as you are not the creator");
        _;
    }

    function createProject(string memory title, string memory description) public {
                
        project storage newProject = projects[numProject];
        newProject.title = title;
        newProject.description = description;
        newProject.serviceRequester = msg.sender;
        newProject.exist = true;
        newProject.projectstatus = ProjectStatus.active;

        emit projectCreated(numProject, title, msg.sender);
        
        numProject++; 
    }

    function addService(uint256 serviceid, uint256 projectid) public 
            checkValidProject(projectid) 
            // onlyOwner(projectid, msg.sender)
        {
        // require(projects[projectid].serviceRequester == msg.sender, "You are not authorized to edit this project as you are not the creator");

        projects[projectid].services.push(serviceid);
    }

    function getRequester(uint256 projectid) public view returns (address){
        return projects[projectid].serviceRequester;
    }

    function getNumProviders(uint256 projectid) public view returns (uint256){
        return projects[projectid].services.length;
    }
}
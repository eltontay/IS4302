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

    uint256 public numProject = 1;
    mapping(uint256 => project) projects;

    event projectCreated(uint256 projectid, string title, address serviceRequester);

    modifier checkValidProject(uint256 projectid) {
        require(projects[projectid].exist, "This project has not been created yet. Please create project first");
        require(projects[projectid].projectstatus == ProjectStatus.active, "This project is no longer active, please activate it first");
        _;
    }

    modifier onlyOwner(uint256 projectid, address user) {
        require (project[projectid].serviceRequester == user, "You are not authorized to edit this project as you are not the creator");
        _;
    }

    function createProject(string memory title, string memory description) {
                
        project storage newProject = projects[numProject];
        newProject.title = title;
        newProject.description = description;
        newProject.serviceRequester = msg.sender;
        newProject.exist = true;
        newProject.projectstatus = ProjectStatus.active;

        numProject++; 
        emit projectCreated(projectid, title, serviceRequester);
    }

    function addService(uint256 serviceid, uint256 projectid) public 
            checkValidProject(projectid) 
            onlyOwner(projectid, msg.sender)
        {
        require(project[projectid].serviceRequester == msg.sender, "You are not authorized to edit this project as you are not the creator");

        project[projectid].services.push(serviceid);
    }

    function getRequester(uint256 projectid) public returns (address){
        return project[projectid].serviceRequester;
    }
}
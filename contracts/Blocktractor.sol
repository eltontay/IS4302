// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Profile.sol";
import "./Project.sol";
import "./States.sol";

// Review -> Profile -> Blocktractor
// Conflict -> Milestone -> Service -> Project -> Blocktractor 

// Payments in blocktractor also needs to be done.



// WorkFlow 1
// Step 1 : Create Profile
// Step 2 : Create Project -- Project Owner (Service Requester)
// Step 3 : Create Service(s) -- Project Owner (Service Requester)
// Step 4 : Create Milestone(s) for each Service(s) -- Project Owner (Service Requester)

// WorkFlow 2
// Step 1 : Finish Project
// Step 2 : Review Profile

// Workflow 3
// Step 1 : Finish Milestone -- Service Provider
// Step 2 : Create Conflict -- Project Owner (Service Requester)

// Once all completed, come together then do payments

contract Blocktractor {

    Profile profileContract;
    Project projectContract;

    address payable escrow_wallet = payable(msg.sender);
    address payable revenue_wallet = payable(msg.sender);
    uint256 public comissionFee;

    constructor(Profile profileContract, Project projectContract, uint256 fee) public {
        profile = profileContract;
        project = projectContract;
        comissionFee = fee;
    }

/*
    Modifiers
*/


// function in blocktractor , first filters out using a function from project to see if it is completed, enum status,
// only then allows person to review the profile.

// function 1 : Project 
// function 2 : Review Profile in Review


   /*
        Project - Create 
    */
    
    function createProject(string memory title, string memory description) public {
        project.createProject(title,description);
    }

    /*
        Project - Read 
    */

    function readProjectTitle(uint256 projectNumber) public view returns (string memory) {
        project.readProjectTitle(projectNumber);
    }

    /*
        Project - Update 
    */
    
    function updateProject(uint256 projectNumber, string memory title, string memory description) public  {
        project.updateProject(projectNumber,title,decription);
    }

    /*
        Project - Delete 
    */
    
    function deleteProject(uint256 projectNumber) public {
        project.deleteProject(projectNumber);
    }

    /*
        Service - Create
    */

    function createService(uint256 projectNumber, string memory title, string memory description, uint256 price) public {
        project.createService(projectNumber,title,description,price);
    }

    /*
        Service - Read
    */

    function readServiceTitle(uint256 projectNumber, uint256 serviceNumber) public view returns (string memory) {
        project.readServiceTitle(projectNumber,serviceNumber);
    }

    /*
        Service - Update
    */

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price) public {
        project.updateService(projectNumber,serviceNumber,title,description,price);
    }

    /*
        Service - Delete
    */

    function deleteService(uint256 projectNumber, uint256 serviceNumber) public {
        project.deleteService(projectNumber,serviceNumber);
    }

    /*
        Milestone - Create
    */

    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone) public {
        project.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Read
    */   

    function readMilestoneTitle(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (string memory) {
        project.readMilestoneTitle(projectNumber,serviceNumber,milestoneNumber);
    }

    /*
        Milestone - Update
    */

    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory titleMilestone, string memory descriptionMilestone) public {
        project.updateMilestone(projectNumber,serviceNumber,milestoneNumber,titleMilestone,descriptionMilestone);
    }

    /*
        Milestone - Delete
    */ 

    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        project.deleteMilestone(projectNumber,serviceNumber,milestoneNumber);
    }    

    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description, address serviceRequester, address serviceProvider,  uint256 totalVoters) external {
        project.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,serviceRequester,serviceProvider,totalVoters);
    }

    /*
        Conflict - Update
    */

    function updateConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external {
        project.updateConflict(projectNumber,serviceNumber,milestoneNumber,title,description);
    }

    /*
        Conflict - Delete
    */ 

    function deleteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external {
        project.deleteConflict(projectNumber,serviceNumber,milestoneNumber);  
    }

    /*
        Conflict - Vote
    */

    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address sender, uint8 vote) external {
        project.voteConflict(projectNumber,serviceNumber,milestoneNumber,sender,vote);
    }

/*
    Getter Helper Functions
*/

    function getProjectOwner(uint256 projectId) public view returns(address) {
        return projects[projectId].projectOwner;
    }

}
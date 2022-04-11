// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Profile.sol";
import "./Project.sol";
import "./States.sol";

contract Blocktractor {

    Profile profile;
    Project project;

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

/*
    Profile Functions - Frontend 
*/

    /*
        Profile - Create
    */
    function createProfile(string memory name, string memory password) public {
        profile.createProfile(name, password, msg.sender);
    }

    /*
        Profile - Delete
    */
    function deleteProfile() public {
        profile.deleteProfile(msg.sender);
    }

    /*
        Profile - Update
    */
    function updateProfileName(string memory name, string memory password ) public {
        profile.updateProfileName(name, password, msg.sender);
    }


    // Getter for name of profile given that it is valid
    function getName() public view returns ( string memory) {
        return profile.getName(msg.sender);
    }

/*

    Project Functions

*/

    /*
        Project - Create 
    */
    
    function createProject(string memory title, string memory description) public {
        project.createProject(title,description, msg.sender);
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
        project.updateProject(projectNumber,title,description,msg.sender);
    }

    /*
        Project - Delete 
    */
    
    function deleteProject(uint256 projectNumber) public {
        project.deleteProject(projectNumber,msg.sender);
    }

/*

    Service Functions 

*/

    /*
        Service - Create
    */

    function createService(uint256 projectNumber, string memory title, string memory description) public {
        project.createService(projectNumber,title,description,msg.sender);
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

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price, States.ServiceStatus status) public {
        project.updateService(projectNumber,serviceNumber,title,description,price,status,msg.sender);
    }

    /*
        Service - Delete
    */

    function deleteService(uint256 projectNumber, uint256 serviceNumber) public {
        project.deleteService(projectNumber,serviceNumber,msg.sender);
    }

    /*
        Service - Accept service request  
        Function for project owner to accept a contractor's service 
    */

    function acceptServiceRequest(uint256 projectNumber, uint256 serviceNumber) public {
        project.acceptServiceRequest(projectNumber,serviceNumber,msg.sender);
    }

    /*
        Service - Reject service request  
        Function for project owner to reject a contractor's service 
    */

    function rejectServiceRequest(uint256 projectNumber, uint256 serviceNumber) public {
        project.rejectServiceRequest(projectNumber,serviceNumber,msg.sender);   
    }

    /*
        Service - Request to start service 
        Function for contractor to request to start a service 
    */

    function takeServiceRequest(uint256 projectNumber, uint256 serviceNumber) public {
        project.takeServiceRequest(projectNumber, serviceNumber, msg.sender);
    }

    /*
        Service - Complete service request
    */

    function completeServiceRequest(uint256 projectNumber, uint256 serviceNumber) public {
        project.completeServiceRequest(projectNumber, serviceNumber, msg.sender);      
    }

/*

    Milestone Functions

*/

    /*
        Milestone - Create
    */

    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone) public {
        project.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone,msg.sender);
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
        project.updateMilestone(projectNumber,serviceNumber,milestoneNumber,titleMilestone,descriptionMilestone,msg.sender);
    }

    /*
        Milestone - Delete
    */ 

    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        project.deleteMilestone(projectNumber,serviceNumber,milestoneNumber,msg.sender);
    } 

    /*
        Milestone - Complete Milestone
    */ 

    function completeMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        project.completeMilestone(projectNumber,serviceNumber,milestoneNumber,msg.sender);
    }    

    /*
        Milestone - Verify Milestone
    */ 

    function verifyMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        project.verifyMilestone(projectNumber,serviceNumber,milestoneNumber,msg.sender);
    } 

/*

    Review Functions

*/

    /*
        Review - Create 
    */

    function reviewMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from, string memory review_input, uint star_rating) public {
        project.reviewMilestone(projectNumber,serviceNumber,milestoneNumber,_from,review_input,star_rating);
    }

    /*
        Review - Getter Provider Stars
    */

    function getAvgServiceProviderStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        return project.getAvgServiceProviderStarRating(projectNumber,serviceNumber);
    }

    /*
        Review - Getter Requester Stars
    */

    function getAvgServiceRequesterStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        return project.getAvgServiceRequesterStarRating(projectNumber,serviceNumber);
    }

/*

    Conflict Functions

*/

    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description, uint256 totalVoters) public {
        project.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,msg.sender,totalVoters);
    }

    /*
        Conflict - Update
    */

    function updateConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) public {
        project.updateConflict(projectNumber,serviceNumber,milestoneNumber,title,description);
    }

    /*
        Conflict - Delete
    */ 

    function deleteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        project.deleteConflict(projectNumber,serviceNumber,milestoneNumber);  
    }

    /*
        Conflict - Start Vote
    */
    function startVote(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        project.startVote(projectNumber, serviceNumber, milestoneNumber,msg.sender);
    }

    /*
        Conflict - Vote
    */

    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, uint8 vote) public {
        project.voteConflict(projectNumber,serviceNumber,milestoneNumber,msg.sender,vote);
    }

}
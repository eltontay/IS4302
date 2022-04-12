// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Profile.sol";
import "./Project.sol";
import "./ERC20.sol";
import "./States.sol";

contract Blocktractor {

    Profile profile;
    Project project;
    ERC20 erc20;


    address payable escrow;
    // address payable revenue_wallet = payable(msg.sender);
    uint256 public comissionFee;

    constructor(Profile profileContract, Project projectContract, uint256 fee) public {
        profile = profileContract;
        project = projectContract;
        escrow = payable(msg.sender);
        erc20 = new ERC20();
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


    function getProjectOwner(uint256 projectId) public view returns(address) {
        project.getProjectOwner(projectId);
    }

    function getProjectTitle(uint256 projectId) public view returns(string memory) {
        project.getProjectTitle(projectId);
    }

    function getProjectDescription(uint256 projectId) public view returns(string memory) {
        project.getProjectDescription(projectId);
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
        Service - Update
    */

    function updateService(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price, States.ServiceStatus status) public {
        project.updateService(projectNumber,serviceNumber,title,description,price,status,msg.sender);
    }

    /*
        Service - Delete
    */

    function deleteService(uint256 projectNumber, uint256 serviceNumber) public {
        project.deleteService(projectNumber,serviceNumber,msg.sender,erc20);
    }

    /*
        Service - Accept service request  
        Function for project owner to accept a contractor's service 
    */

    function acceptServiceRequest(uint256 projectNumber, uint256 serviceNumber) external {
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

    function getServiceTitle(uint256 projectNumber, uint256 serviceNumber) public view returns(string memory) {
        project.getServiceTitle(projectNumber,serviceNumber);
    }

    function getServiceDescription(uint256 projectNumber, uint256 serviceNumber) public view returns(string memory) {
        project.getServiceDescription(projectNumber,serviceNumber);
    }   

/*

    Milestone Functions

*/

    /*
        Milestone - Create
    */

    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone, uint256 price) public {
        project.createMilestone(projectNumber,serviceNumber,titleMilestone,descriptionMilestone, price, msg.sender);
        //make payment to escrow
        erc20.transfer(escrow, price);
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
        project.deleteMilestone(projectNumber,serviceNumber,milestoneNumber,msg.sender,erc20);
    } 

    /*
        Milestone - Complete Milestone
    */ 

    function completeMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        project.completeMilestone(projectNumber,serviceNumber,milestoneNumber,msg.sender);
    }    

    /*
        Milestone - Make milestone payment
    */ 

    function makeMilestonePayment(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        project.makeMilestonePayment(projectNumber,serviceNumber,milestoneNumber, erc20);
    }    

/*

    Conflict Functions

*/

    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external {
        project.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,msg.sender);
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
        Conflict - Start Vote
    */
    function startVote(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external {
        project.startVote(projectNumber, serviceNumber, milestoneNumber);
    }

    /*
        Conflict - Vote
    */

    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, uint8 vote) external {
        project.voteConflict(projectNumber,serviceNumber,milestoneNumber,msg.sender,vote);
    }

    /*
        Conflict - Resolve conflict payment 
    */
    function resolveConflictPayment(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public {
        project.resolveConflictPayment( projectNumber,  serviceNumber,  milestoneNumber,  erc20);
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

}
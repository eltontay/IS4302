// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Conflict.sol";
import "./States.sol";

contract Milestone {

    Conflict conflict;

    constructor (Conflict conflictContract) public {
        conflict = conflictContract;
    }

    struct milestone {
        uint256 projectNumber;
        uint256 serviceNumber;
        uint256 milestoneNumber;
        string title;
        string description;
        bool exist; // allowing updates such as soft delete of milestone   
        States.MilestoneStatus status; // Defaults at none
    }

    mapping (uint256 => mapping(uint256 => mapping(uint256 => milestone))) servicesMilestones; // [projectNumber][serviceNumber][milestoneNumber]

    event milestoneCreated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string title, string description);
    event milestoneUpdated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string title, string description);
    event milestoneDeleted(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber);

    uint256 milestoneTotal = 0;
    uint256 milestoneNum = 0;

/*
    Modifiers
*/

/*
    CUD Milestones
*/

    /*
        Milestone - Create
    */

    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description) external {

        milestone storage newMilestone = servicesMilestones[projectNumber][serviceNumber][milestoneNum];
        newMilestone.projectNumber = projectNumber;
        newMilestone.serviceNumber = serviceNumber;
        newMilestone.milestoneNumber = milestoneNum;
        newMilestone.title = title;
        newMilestone.description = description;
        newMilestone.exist = true;
        newMilestone.status = States.MilestoneStatus.none;

        emit milestoneCreated(projectNumber, serviceNumber, milestoneNum, title, description);

        milestoneTotal++;
        milestoneNum++;

    }

    /*
        Milestone - Read 
    */

    function readMilestoneTitle(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external view returns (string memory) {
        return (servicesMilestones[projectNumber][serviceNumber][milestoneNumber].title);
    }

    /*
        Milestone - Update
    */

    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external {
        
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].title = title;
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].description = description;

        emit milestoneUpdated(projectNumber, serviceNumber, milestoneNumber, title, description);
    }

    /*
        Milestone - Delete
    */ 

    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external {

        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].exist = false;        

        milestoneTotal--;

        emit milestoneDeleted(projectNumber, serviceNumber, milestoneNumber);
    }

    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description, address serviceRequester, address serviceProvider,  uint256 totalVoters) external {
        conflict.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,serviceRequester,serviceProvider,totalVoters);
    }

    /*
        Conflict - Update
    */

    function updateConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external {
        conflict.updateConflict(projectNumber,serviceNumber,milestoneNumber,title,description);
    }

    /*
        Conflict - Delete
    */ 

    function deleteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external {
        conflict.deleteConflict(projectNumber,serviceNumber,milestoneNumber);  
    }

    /*
        Conflict - Vote
    */

    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address sender, uint8 vote) external {
        conflict.voteConflict(projectNumber,serviceNumber,milestoneNumber,sender,vote);
    }

/*
    Getter Helper Functions
*/

    function getResults(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint) {
        return conflict.getResults(projectNumber,serviceNumber,milestoneNumber);
    }

    function getConflictStatus(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns ( States.ConflictStatus ) {
        return conflict.getConflictStatus(projectNumber,serviceNumber,milestoneNumber);
    }

    function getVotesCollected(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint256) {
        return conflict.getVotesCollected(projectNumber,serviceNumber,milestoneNumber);
    }

    function getVotesforRequester(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint256) {
        return conflict.getVotesforRequester(projectNumber,serviceNumber,milestoneNumber);
    }

    function getVotesforProvider(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint256) {
        return conflict.getVotesforProvider(projectNumber,serviceNumber,milestoneNumber);
    }


}


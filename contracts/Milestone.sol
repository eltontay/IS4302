// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Conflict.sol";

contract Milestone {

    Conflict conflict;

    constructor (Conflict conflictContract) public {
        conflict = conflictContract;
    }

    enum Status { none, pending, approved, started, completed, verified, conflict}

    struct milestone {
        uint256 projectNumber;
        uint256 serviceNumber;
        uint256 milestoneNumber;
        string title;
        string description;
        bool exist; // allowing updates such as soft delete of milestone   
        Status status; // Defaults at none
    }

    mapping (uint256 => mapping(uint256 => milestone[])) servicesMilestones; // [projectNumber][serviceNumber][milestoneNumber]

    event milestoneCreated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string title, string description);
    event milestoneUpdated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string title, string description);
    event milestoneDeleted(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber);

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
        uint256 milestoneNumber = servicesMilestones[projectNumber][serviceNumber].length + 1;
        milestone memory newMilestone = milestone(projectNumber, serviceNumber, milestoneNumber, title, description, true, Status.pending);
        servicesMilestones[projectNumber][serviceNumber].push(newMilestone);

        emit milestoneCreated(projectNumber, serviceNumber, milestoneNumber, title, description);
    }

    /*
        Milestone - Read 
    */

    function readMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (string memory , string memory ) {
        return (
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].title, 
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].description
        );
    }

    /*
        Milestone - Update
    */
    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external {
        milestone memory newMilestone = milestone(projectNumber, serviceNumber, milestoneNumber, title, description, true, Status.pending);
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber] = newMilestone;

        emit milestoneUpdated(projectNumber, serviceNumber, milestoneNumber, title, description);
    }

    /*
        Milestone - Delete
    */ 
    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external {
        for (uint i = milestoneNumber; i < servicesMilestones[projectNumber][serviceNumber].length-1; i++){
            servicesMilestones[projectNumber][serviceNumber][i] = servicesMilestones[projectNumber][serviceNumber][i+1];
        }
        servicesMilestones[projectNumber][serviceNumber].pop();

        emit milestoneDeleted(projectNumber, serviceNumber, milestoneNumber);
    }


}



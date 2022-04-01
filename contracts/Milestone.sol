// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Milestone {

    constructor () public {

    }

    enum Status { none, pending, approved, started, completed, verified, conflict}

    struct milestone {
        uint256 projectNumber;
        uint256 serviceNumber;
        uint256 milestoneNumber;
        string milestoneTitle;
        string milestoneDescription;
        bool exist; // allowing updates such as soft delete of milestone   
        Status status; // Defaults at none
    }

    mapping (uint256 => mapping(uint256 => milestone[])) servicesMilestones; // [projectNumber][serviceNumber][milestoneNumber]

    event milestoneCreated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string titleMilestone, string descriptionMilestone);
    event milestoneUpdated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string titleMilestone, string descriptionMilestone);
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
    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone) external {
        uint256 milestoneNumber = servicesMilestones[projectNumber][serviceNumber].length + 1;
        milestone memory newMilestone = milestone(projectNumber, serviceNumber, milestoneNumber, titleMilestone, descriptionMilestone, true, Status.pending);
        servicesMilestones[projectNumber][serviceNumber].push(newMilestone);

        emit milestoneCreated(projectNumber, serviceNumber, milestoneNumber, titleMilestone, descriptionMilestone);
    }

    /*
        Milestone - Update
    */
    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory titleMilestone, string memory descriptionMilestone) external {
        milestone memory newMilestone = milestone(projectNumber, serviceNumber, milestoneNumber, titleMilestone, descriptionMilestone, true, Status.pending);
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber] = newMilestone;

        emit milestoneUpdated(projectNumber, serviceNumber, milestoneNumber, titleMilestone, descriptionMilestone);
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



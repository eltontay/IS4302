// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// import "@openzeppelin/contracts/utils/Strings.sol";

contract Milestone {

    enum Status { none, pending, approved, started, completed, verified, conflict}

    struct milestone {
        string milestoneTitle;
        string milestoneDescription;
        // bool exist; // allowing updates such as soft delete of milestone   
        Status status; // Defaults at none
    }

    mapping (uint256 => milestone[]) milestones; // indexed mapping of services to multiple milestones

    event milestoneStatusChanged(uint256 serviceNumber, uint256 milestoneNumber, Status statusBefore, Status statusAfter);
    event milestoneCreated(uint256 serviceNumber, milestone newMilestone, uint256 numMilestones);
    event milestoneUpdated(uint256 serviceNumber, uint256 milestoneNumber, milestone newMilestone, milestone oldMilestone);
    event milestoneDeleted(uint256 serviceNumber, uint256 milestoneNumber, milestone milestoneDeleted, uint256 numMilestones);
    event milestoneCompleted(uint256 serviceNumber, uint256 milestoneNumber);

    modifier doMilestonesExist(uint256 serviceNumber) {
        require(milestones[serviceNumber].length != 0, "Milestones have not been created yet");
        _;
    }

    modifier doSpecificMilestoneExist(uint256 serviceNumber, uint256 numMilestone) {        
        require(numMilestone < milestones[serviceNumber].length, "Milestone number out of range");
        _;
    }



/*
    CUD Milestones
*/

    // Create Milestones 
    // can only be called externally 
    function createMilestone(uint256 serviceNumber, string memory titleMilestone, string memory descriptionMilestone) external {
        milestone memory newMilestone = milestone(titleMilestone, descriptionMilestone, Status.pending);
        milestones[serviceNumber].push(newMilestone);

        emit milestoneCreated(serviceNumber, newMilestone, milestones[serviceNumber].length);
    }

    // Updating Milestone 
    // edits both title and description
    function updateMilestone(uint256 serviceNumber, uint256 milestoneNum, string memory titleMilestone, string memory descriptionMilestone) external doMilestonesExist(serviceNumber) {
        milestone memory newMilestone = milestone(titleMilestone, descriptionMilestone, Status.pending);
        milestone memory oldMilestone = milestones[serviceNumber][milestoneNum];

        milestones[serviceNumber][milestoneNum] = newMilestone;

        emit milestoneUpdated(serviceNumber, milestoneNum, newMilestone, oldMilestone);
    }

    // Delete Milestones 
    // removing milestone by position and moving all milestones down
    function deleteMilestone(uint256 serviceNumber, uint256 milestoneNum) external doMilestonesExist(serviceNumber) {
        milestone memory deletedMilestone = milestones[serviceNumber][milestoneNum];

        for (uint i = milestoneNum; i < milestones[serviceNumber].length-1; i++){
            milestones[serviceNumber][i] = milestones[serviceNumber][i+1];
        }
        milestones[serviceNumber].pop();

        emit milestoneDeleted(serviceNumber, milestoneNum, deletedMilestone, milestones[serviceNumber].length);
    }



/*
    Status changes functions 
*/

    // Updating Milestone Status to selected function 
    function updateMilestoneStatus(uint256 serviceNumber, uint256 milestoneNum, Status status) internal doMilestonesExist(serviceNumber) {
        Status curStatus = milestones[serviceNumber][milestoneNum].status;
        milestones[serviceNumber][milestoneNum].status = status;

        emit milestoneStatusChanged(serviceNumber, milestoneNum, curStatus, status);
    }

    // Updating all Milestones to pending since cancel request is called by Service Requester
    function updateAllMilestonePending(uint256 serviceNumber) external {
        for (uint i = 0; i < milestones[serviceNumber].length; i++){
            updateMilestoneStatus(serviceNumber, i, Status.pending);
        }
    }

    // Updating Milestone status to approved
    function updateMilestoneApproved(uint256 serviceNumber, uint256 milestoneNum) external doMilestonesExist(serviceNumber) {
        updateMilestoneStatus(serviceNumber, milestoneNum, Status.approved);
    }

    // Updating Milestone status to started
    function updateMilestoneStarted(uint256 serviceNumber, uint256 milestoneNum) external doMilestonesExist(serviceNumber) {
        updateMilestoneStatus(serviceNumber, milestoneNum, Status.started);
    }

    // Updating Milestone status to completed
    function updateMilestoneCompleted(uint256 serviceNumber, uint256 milestoneNum) external doMilestonesExist(serviceNumber) {
        updateMilestoneStatus(serviceNumber, milestoneNum, Status.completed);
    }

    // Updating Milestone status to completed
    function updateMilestoneVerified(uint256 serviceNumber, uint256 milestoneNum) external doMilestonesExist(serviceNumber) {
        updateMilestoneStatus(serviceNumber, milestoneNum, Status.verified);
    }

    // Updating Milestone status to conflict
    function updateMilestoneConflict(uint256 serviceNumber, uint256 milestoneNum) external doMilestonesExist(serviceNumber) {
        updateMilestoneStatus(serviceNumber, milestoneNum, Status.conflict);
    }



/*
    Getter Functions 
*/

    // Get Milestone status 
    function getMilestoneStatus(uint256 serviceNumber, uint256 milestoneNumber) public view doMilestonesExist(serviceNumber) doSpecificMilestoneExist(serviceNumber, milestoneNumber) returns (Status) {
        return milestones[serviceNumber][milestoneNumber].status;
    }

    // Get All Milestone 
    function getAllMilestone(uint256 serviceNumber) public view doMilestonesExist(serviceNumber) returns (milestone[] memory) {
        return milestones[serviceNumber];
    }

    // Get Total Milestones Number
    function getTotalNumMilestones(uint256 serviceNumber) public view doMilestonesExist(serviceNumber) returns (uint256) {
        return milestones[serviceNumber].length;
    }



/*
    Checker Functions 
*/

    // Check if all Milestone status matches
    function checkAllMilestoneStatusMatch(uint256 serviceNumber, Status state) internal view returns (bool) {
        for (uint256 i = 0; i < milestones[serviceNumber].length; i++) {
            if (milestones[serviceNumber][i].status != state) {
                return false;
            }
        }
        return true;
    }

    // Check if at least one Milestone is created
    function checkMinMilestoneCreated(uint256 serviceNumber) public view returns (bool) {
        return milestones[serviceNumber].length != 0;
    }

    // Check if Milestone status corresponds
    function checkMilestoneStatus(uint256 serviceNumber, uint256 milestoneNumber, uint8 status) public view returns (bool) {
        return uint8(milestones[serviceNumber][milestoneNumber].status) == status;
    }

    //Check if all Milestone status are approved
    function checkAllMilestoneApproved(uint256 serviceNumber) public view returns (bool) {
        return checkAllMilestoneStatusMatch(serviceNumber, Status.approved);
    }

    //Check if all Milestone status are completed
    function checkAllMilestoneCompleted(uint256 serviceNumber) public view returns (bool) {
        return checkAllMilestoneStatusMatch(serviceNumber, Status.completed);
    }

    //Check if all Milestone status are verified
    function checkAllMilestoneVerified(uint256 serviceNumber) public view returns (bool) {
        return checkAllMilestoneStatusMatch(serviceNumber, Status.verified);
    }

    // Check if any Milestone status matches conflict
    function checkAnyMilestoneStatusMatch(uint256 serviceNumber, Status state) internal view returns (bool) {
        for (uint256 i = 0; i < milestones[serviceNumber].length; i++) {
            if (milestones[serviceNumber][i].status == state) {
                return false;
            }
        }
        return true;
    }

    //Check if any Milestones status are conflict
    function checkAnyMilestoneConflict(uint256 serviceNumber) public view returns (bool) {
        return checkAnyMilestoneStatusMatch(serviceNumber, Status.conflict);
    }


}



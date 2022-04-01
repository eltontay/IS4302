// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
// import "./Service.sol";

// Vote 1 for Service Requester, Vote 2 for Service Provider 

contract Conflict {

    enum ConflictStatus { none, pending, completed }

    struct conflict {
        uint256 projectNumber;
        uint256 serviceNumber;
        uint256 milestoneNumber;
        address serviceRequester; // Project Owner
        address serviceProvider; 
        ConflictStatus conflictstatus;
        uint256 voters;
        uint256 votesCollected;
        uint256 requesterVotes;
        uint256 providerVotes;
        bool exists;
        uint8 result;
        mapping(address => uint8) votes;
    }

    mapping (uint256 => mapping( uint256 => mapping (uint256 => conflict))) conflicts; // [projectNumber][serviceNumber][milestoneNumber] -> conflict


    event conflictCreated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address serviceRequester, address serviceProvider, uint256 totalVoters);

    event conflictRaised(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address serviceProvider);
    event conflictVoted(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address voter, uint8 vote);
    event conflictResult(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, uint8 result);

    /*
        Conflict - Create
    */
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address serviceRequester, address serviceProvider,  uint256 totalVoters) public {
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].exists != true , "Conflict has already been created. Please do not create more than 1 conflict."); //bool defaults to false

        conflict storage newConflict = conflicts[projectNumber][serviceNumber][milestoneNumber];
        newConflict.projectNumber = projectNumber;     
        newConflict.serviceNumber = serviceNumber;        
        newConflict.milestoneNumber = milestoneNumber;
        newConflict.serviceRequester = serviceRequester;
        newConflict.serviceProvider = serviceProvider;
        newConflict.conflictstatus = ConflictStatus.pending;
        newConflict.voters = totalVoters;
        newConflict.votesCollected = 0;
        newConflict.requesterVotes = 0;
        newConflict.providerVotes = 0;    
        newConflict.exists = true;
        newConflict.result = 0;

        emit conflictCreated(projectNumber, serviceNumber, milestoneNumber, serviceRequester, serviceProvider, totalVoters);
    }

    /*
        Conflict - Read
    */

    /*
        Conflict - Update
    */



    /*
        Conflict - Delete
    */


    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address sender, uint8 vote) public {
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].serviceRequester != sender , "You raised this conflict. You cannot vote on it.");
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].serviceProvider != sender, "You are involved in this conflict. You cannot vote on it.");
        
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].votesCollected < conflicts[projectNumber][serviceNumber][milestoneNumber].voters, "Enough votes have been collected");
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].votes[sender] == 0 , "You have already voted, you cannot vote again");
        require(vote == 1 || vote == 2, "You have not input a right vote. You can either vote 1 for Requester or 2 for Provider.");

        conflict storage C = conflicts[projectNumber][serviceNumber][milestoneNumber];
        C.votes[sender] = vote;

        if (vote == 1) { C.requesterVotes++; }
        if (vote == 2) { C.providerVotes++; }
        C.votesCollected++;

        emit conflictVoted(projectNumber, serviceNumber, milestoneNumber, msg.sender, vote);

        if (C.votesCollected == C.voters) {
            if (C.providerVotes > C.requesterVotes) {C.result = 2; }
            else {C.result = 1;} //if there is tie vote, service Requester will win the vote
            C.conflictstatus = ConflictStatus.completed;

            emit conflictResult(projectNumber, serviceNumber, milestoneNumber, C.result);
        }
    }


/*

    Getter Functions 

*/

    function getResults(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint) {
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].votesCollected == conflicts[projectNumber][serviceNumber][milestoneNumber].voters, "Not everyone has voted, please prompt all other members of project to vote");
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].conflictstatus == ConflictStatus.completed, "Voting has not been completed yet. Please wait for it to end.");

        return conflicts[projectNumber][serviceNumber][milestoneNumber].result;
    }

    function getConflictStatus(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (ConflictStatus) {
        return conflicts[projectNumber][serviceNumber][milestoneNumber].conflictstatus;
    }

    function getVotesCollected(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint256) {
        return conflicts[projectNumber][serviceNumber][milestoneNumber].votesCollected;
    }

    function getVotesforRequester(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint256) {
        return conflicts[projectNumber][serviceNumber][milestoneNumber].requesterVotes;
    }

    function getVotesforProvider(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint256) {
        return conflicts[projectNumber][serviceNumber][milestoneNumber].providerVotes;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./States.sol";

// Vote 1 for Service Requester, Vote 2 for Service Provider 
// Each milestone can hold one conflict

contract Conflict {

    struct conflict {
        uint256 projectNumber;
        uint256 serviceNumber;
        uint256 milestoneNumber;
        string title;
        string description;
        address  serviceRequester; // Project Owner
        address  serviceProvider; 
        States.ConflictStatus conflictStatus;
        uint256 voters;
        uint256 votesCollected;
        uint256 requesterVotes;
        uint256 providerVotes;
        bool exist; // soft delete , default is false. 
        uint8 result;
        mapping(address => uint8) votes;
    }

    mapping (uint256 => mapping( uint256 => mapping (uint256 => conflict))) conflicts; // [projectNumber][serviceNumber][milestoneNumber] -> conflict

    event conflictCreated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address serviceRequester, address serviceProvider, uint256 totalVoters);
    event conflictRaised(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address serviceProvider);
    event conflictVoted(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address voter, uint8 vote);
    event conflictResult(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, uint8 result);

    /*
        Modifiers
    */
    modifier isValidConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber){
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].exist, "This Conflict does not exist.");
        _;
    }

    modifier atState(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, States.ConflictStatus state){
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].conflictStatus == state, "Cannot carry out this operation!");
        _;
    }

    modifier requiredString(string memory str) {
        require(bytes(str).length > 0, "A string is required!");
        _;
    }

    modifier canVote(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address sender){
        conflict storage currConflict = conflicts[projectNumber][serviceNumber][milestoneNumber];
        require(currConflict.serviceRequester != sender , "You raised this conflict. You cannot vote on it.");
        require(currConflict.serviceProvider != sender, "You are involved in this conflict. You cannot vote on it.");
        _;
    }

    /*
        Setters
    */

    function setState(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, States.ConflictStatus state) internal {
        conflicts[projectNumber][serviceNumber][milestoneNumber].conflictStatus = state;
    }

    /*
        Conflict - Create
    */

    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description, address  serviceRequester, address serviceProvider, uint256 totalVoters) public 
        requiredString(title)
        requiredString(description)
    {
        conflict storage newConflict = conflicts[projectNumber][serviceNumber][milestoneNumber];
        require(newConflict.exist == false, "Conflict has already been created for this particular Milestone."); //bool defaults to false
        newConflict.projectNumber = projectNumber;     
        newConflict.serviceNumber = serviceNumber;        
        newConflict.milestoneNumber = milestoneNumber;
        newConflict.title = title;
        newConflict.description = description;
        newConflict.serviceRequester = serviceRequester;
        newConflict.serviceProvider = serviceProvider;
        newConflict.conflictStatus = States.ConflictStatus.created;
        newConflict.voters = totalVoters;
        newConflict.votesCollected = 0;
        newConflict.requesterVotes = 0;
        newConflict.providerVotes = 0;    
        newConflict.exist = true;
        newConflict.result = 0;

        emit conflictCreated(projectNumber, serviceNumber, milestoneNumber, serviceRequester, serviceProvider, totalVoters);

        if (newConflict.voters == 0) {

        }

    }

    /*
        Conflict - Update
    */

    function updateConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external 
        atState(projectNumber, serviceNumber, milestoneNumber,States.ConflictStatus.created)
        requiredString(title)
        requiredString(description)
    {
        conflicts[projectNumber][serviceNumber][milestoneNumber].title = title;
        conflicts[projectNumber][serviceNumber][milestoneNumber].description = description;
    }

    /*
        Conflict - Delete
    */ 

    function deleteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external 
        isValidConflict(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber,States.ConflictStatus.created)
    {
        conflicts[projectNumber][serviceNumber][milestoneNumber].exist = false;  
        setState(projectNumber, serviceNumber, milestoneNumber, States.ConflictStatus.terminated);      
    }

    /*
        Conflict- Start Vote
    */
    function startVote(uint256 projectNumber,uint256 serviceNumber, uint256 milestoneNumber) external 
        isValidConflict(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber,States.ConflictStatus.created)
    {
        setState(projectNumber, serviceNumber, milestoneNumber, States.ConflictStatus.voting);
    }

    /*
        Conflict - Vote
    */

    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address _from, uint8 vote) public 
        isValidConflict(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber,States.ConflictStatus.voting)
    returns (bool) {
        conflict storage currConflict = conflicts[projectNumber][serviceNumber][milestoneNumber];
        require(currConflict.serviceRequester != _from , "You raised this conflict. You cannot vote on it.");
        require(currConflict.serviceProvider != _from, "You are involved in this conflict. You cannot vote on it.");
        require(currConflict.votesCollected < currConflict.voters, "Enough votes have been collected");
        require(currConflict.votes[_from] == 0 , "You have already voted, you cannot vote again");
        require(vote == 1 || vote == 2, "You have not input a right vote. You can either vote 1 for Requester or 2 for Provider.");

        currConflict.votes[_from] = vote;

        if (vote == 1) { currConflict.requesterVotes++; }
        if (vote == 2) { currConflict.providerVotes++; }
        currConflict.votesCollected++;

        emit conflictVoted(projectNumber, serviceNumber, milestoneNumber, msg.sender, vote);

        if (currConflict.votesCollected == currConflict.voters) {
        if (currConflict.providerVotes > currConflict.requesterVotes) {currConflict.result = 2; }
            else {currConflict.result = 1;} //if there is tie vote, service Requester will win the vote
            setState(projectNumber, serviceNumber, milestoneNumber, States.ConflictStatus.completed);

            emit conflictResult(projectNumber, serviceNumber, milestoneNumber, currConflict.result);
            return true;
        }
        return false;
    }     


/*
    Getter Functions 
*/

    function getResults(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint) {
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].votesCollected == conflicts[projectNumber][serviceNumber][milestoneNumber].voters, "Not everyone has voted, please prompt all other members of project to vote");
        require(conflicts[projectNumber][serviceNumber][milestoneNumber].conflictStatus == States.ConflictStatus.completed, "Voting has not been completed yet. Please wait for it to end.");

        return conflicts[projectNumber][serviceNumber][milestoneNumber].result;
    }

    function getConflictStatus(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (States.ConflictStatus) {
        return conflicts[projectNumber][serviceNumber][milestoneNumber].conflictStatus;
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
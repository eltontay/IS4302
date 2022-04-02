// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
// import "./Service.sol";

// Vote 1 for Service Requester, Vote 2 for Service Provider 

contract Conflict {

    enum ConflictStatus { none, pending, completed }

    struct conflict {
        address serviceRequester;
        address serviceProvider;
        uint256 milestoneid;
        uint256 serviceid;
        uint256 projectid;
        ConflictStatus conflictstatus;
        uint256 votestotal;
        uint256 votescollected;
        uint256 votesforRequester;
        uint256 votesforProvider;
        bool exists;
        uint8 result;
        mapping(address => uint8) votes;
    }

    mapping (uint256 => mapping( uint256 => mapping (uint256 => conflict))) conflicts; //project id => service id => milestone id

    event conflictRaised(uint256 projectid, uint256 serviceid, uint256 milestoneid, address serviceProvider);
    event conflictVoted(uint256 projectid, uint256 serviceid, uint256 milestoneid, address voter, uint8 vote);
    event conflictResult(uint256 projectid, uint256 serviceid, uint256 milestoneid, uint8 result);

    function createConflict(uint256 projectid, uint256 serviceid, uint256 milestoneid, address serviceProvider,  uint256 tot_voters) public {
        require(conflicts[projectid][serviceid][milestoneid].exists != true , "Conflict has already been created. Please do not create more than 1 conflict."); //bool defaults to false

        conflict storage newConflict = conflicts[projectid][serviceid][milestoneid];
        newConflict.serviceRequester = msg.sender;
        newConflict.serviceProvider = serviceProvider;
        newConflict.milestoneid = milestoneid;
        newConflict.serviceid = serviceid;
        newConflict.projectid = projectid;
        newConflict.exists = true;
        newConflict.conflictstatus = ConflictStatus.pending;
        newConflict.votestotal = tot_voters;

        emit conflictRaised(projectid, serviceid, milestoneid, serviceProvider);
    }

    function voteConflict(uint256 projectid, uint256 serviceid, uint256 milestoneid, uint8 vote) public {
        require(conflicts[projectid][serviceid][milestoneid].serviceRequester != msg.sender , "You raised this conflict. You cannot vote on it.");
        require(conflicts[projectid][serviceid][milestoneid].serviceProvider != msg.sender, "You are involved in this conflict. You cannot vote on it.");
        
        require(conflicts[projectid][serviceid][milestoneid].votescollected < conflicts[projectid][serviceid][milestoneid].votestotal, "Enough votes have been collected");
        require(conflicts[projectid][serviceid][milestoneid].votes[msg.sender] == 0 , "You have already voted, you cannot vote again");
        require(vote == 1 || vote == 2, "You have not input a right vote. You can either vote 1 for Requester or 2 for Provider.");

        conflict storage C = conflicts[projectid][serviceid][milestoneid];
        C.votes[msg.sender] = vote;

        if (vote == 1) { C.votesforRequester++; }
        if (vote == 2) { C.votesforProvider++; }
        C.votescollected++;

        emit conflictVoted(projectid, serviceid, milestoneid, msg.sender, vote);

        if (C.votescollected == C.votestotal) {
            if (C.votesforProvider > C.votesforRequester) {C.result = 2; }
            else {C.result = 1;} //if there is tie vote, service Requester will win the vote
            C.conflictstatus = ConflictStatus.completed;

            emit conflictResult(projectid, serviceid, milestoneid, C.result);
        }
    }


/*

    Getter Functions 

*/

    function getResults(uint256 projectid, uint256 serviceid, uint256 milestoneid) public view returns (uint) {
        require(conflicts[projectid][serviceid][milestoneid].votescollected == conflicts[projectid][serviceid][milestoneid].votestotal, "Not everyone has voted, please prompt all other members of project to vote");
        require(conflicts[projectid][serviceid][milestoneid].conflictstatus == ConflictStatus.completed, "Voting has not been completed yet. Please wait for it to end.");

        return conflicts[projectid][serviceid][milestoneid].result;
    }

    function getConflictStatus(uint256 projectid, uint256 serviceid, uint256 milestoneid) public view returns (ConflictStatus) {
        return conflicts[projectid][serviceid][milestoneid].conflictstatus;
    }

    function getVotesCollected(uint256 projectid, uint256 serviceid, uint256 milestoneid) public view returns (uint256) {
        return conflicts[projectid][serviceid][milestoneid].votescollected;
    }

    function getVotesforRequester(uint256 projectid, uint256 serviceid, uint256 milestoneid) public view returns (uint256) {
        return conflicts[projectid][serviceid][milestoneid].votesforRequester;
    }

    function getVotesforProvider(uint256 projectid, uint256 serviceid, uint256 milestoneid) public view returns (uint256) {
        return conflicts[projectid][serviceid][milestoneid].votesforProvider;
    }

}

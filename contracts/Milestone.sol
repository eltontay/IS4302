// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Conflict.sol";
import "./States.sol";

contract Milestone {

    Conflict conflict;

    constructor (Conflict conflictContract) {
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

    modifier requiredString(string memory str) {
        require(bytes(str).length > 0, "A string is required!");
        _;
    }

    modifier isValidMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber){
        require(servicesMilestones[projectNumber][serviceNumber][milestoneNumber].exist, "This Milestone does not exist ya dummy!");
        _;
    }

    modifier atState(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, States.MilestoneStatus state){
        require(servicesMilestones[projectNumber][serviceNumber][milestoneNumber].status == state, "Cannot carry out this operation!");
        _;
    }

/*
    Setter Functions
*/
    function setState(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, States.MilestoneStatus state) internal {
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].status = state;
    }

/*
    CUD Milestones
*/

    /*
        Milestone - Create
    */

    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description) external 
        requiredString(title)
        requiredString(description)
    {

        milestone storage newMilestone = servicesMilestones[projectNumber][serviceNumber][milestoneNum];
        newMilestone.projectNumber = projectNumber;
        newMilestone.serviceNumber = serviceNumber;
        newMilestone.milestoneNumber = milestoneNum;
        newMilestone.title = title;
        newMilestone.description = description;
        newMilestone.exist = true;
        newMilestone.status = States.MilestoneStatus.created;

        emit milestoneCreated(projectNumber, serviceNumber, milestoneNum, title, description);

        milestoneTotal++;
        milestoneNum++;
    }

    /*
        Milestone - Read 
    */

    function readMilestoneTitle(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external view 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
    returns (string memory) {
        return (servicesMilestones[projectNumber][serviceNumber][milestoneNumber].title);
    }

    /*
        Milestone - Update
    */

    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.created)
        requiredString(title)
        requiredString(description)
    {
        
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].title = title;
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].description = description;

        emit milestoneUpdated(projectNumber, serviceNumber, milestoneNumber, title, description);
    }

    /*
        Milestone - Delete
    */ 

    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.created)
    {
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].exist = false;        
        milestoneTotal--;
        setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.terminated);
        emit milestoneDeleted(projectNumber, serviceNumber, milestoneNumber);
    }

    /*
        Milestone - Accept
    */
    
    function acceptService(uint256 projectNumber, uint256 serviceNumber) external{
        // Accepts Service Contract, so all the Milestones are set to approved (locked in)
        for (uint i = 0; i < milestoneNum; i++){
            if(servicesMilestones[projectNumber][serviceNumber][i].status != States.MilestoneStatus.created ||
            servicesMilestones[projectNumber][serviceNumber][i].exist == false){ 
                continue; 
            }
            setState(projectNumber, serviceNumber, i, States.MilestoneStatus.approved);
            startNextMilestone(projectNumber, serviceNumber);
        }
    }

    /*
        Milestone - Start
    */

    function startNextMilestone(uint256 projectNumber, uint256 serviceNumber) internal {
        for (uint i = 0; i < milestoneNum; i++){
            if(servicesMilestones[projectNumber][serviceNumber][i].status == States.MilestoneStatus.approved &&
            servicesMilestones[projectNumber][serviceNumber][i].exist){ 
                startMilestone(projectNumber, serviceNumber, i);
                return ;
            }
        }
    }

    function startMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) private
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.approved)
    {
        setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.started);
    }

    /*
        Milestone - Complete
    */
    function completeMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.started) // Must work on milestone in order
    {
        setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.completed);
        startNextMilestone(projectNumber, serviceNumber);
    }

    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description, address serviceRequester, address serviceProvider,  uint256 totalVoters) external 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.completed)
    {
        // Need to set requirement for service requestor?
        conflict.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,serviceRequester,serviceProvider,totalVoters);
        setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.conflict);
    }

    /*
        Conflict - Update
    */

    function updateConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.conflict)
    {
        conflict.updateConflict(projectNumber,serviceNumber,milestoneNumber,title,description);
    }

    /*
        Conflict - Delete
    */ 

    function deleteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.conflict)
    {
        conflict.deleteConflict(projectNumber,serviceNumber,milestoneNumber);  
        setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.completed);
    }

    /*
        Conflict - Start Vote
    */
    function startVote(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.conflict)
    {
        conflict.startVote(projectNumber, serviceNumber, milestoneNumber);
    }

    /*
        Conflict - Vote
    */

    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address sender, uint8 vote) external 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.conflict)
    {
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
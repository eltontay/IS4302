// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Conflict.sol";
import "./Review.sol";
import "./States.sol";
import "./Token.sol";
import "./SafeMath.sol";

/*
    Overview

    Milestone Functions
    - createMilestone
    - updateMilestone
    - deleteMilestone
    - acceptMilestone
    - startNextMilestone
    - completeMilestone
    - makeMilestonePayment
    - reviewMilestone

*/



contract Milestone {
    
    using SafeMath for uint256;

    Conflict conflict;
    Review review;
    Token token;

    // address  contractAddress = (msg.sender); 

    constructor (Conflict conflictContract, Review reviewContract, Token tokenContract)  {
        conflict = conflictContract;
        review = reviewContract;
        token = tokenContract;
    }

    struct milestone {
        uint256 projectNumber;
        uint256 serviceNumber;
        uint256 milestoneNumber;
        string title;
        string description;
        bool exist; // allowing updates such as soft delete of milestone   
        States.MilestoneStatus status; // Defaults at none
        uint256 price;
        address serviceRequester; // msg.sender
        address serviceProvider; // defaults to address(0)
    }

    mapping (uint256 => mapping(uint256 => mapping(uint256 => milestone))) servicesMilestones; // [projectNumber][serviceNumber][milestoneNumber]    
    // mapping (uint256 => mapping(uint256 => uint256)) numMilestoneTracker; // track number of milestone for each project => service

    event milestoneCreated(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string title, string description, uint256 price);
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
        require(servicesMilestones[projectNumber][serviceNumber][milestoneNumber].status == state, "Cannot carry out this operation!- Milestone");
        _;
    }

    modifier isNeither(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address  _from) {
        require(servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceRequester == _from || 
                servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceProvider == _from , "Invalid service requester or provider");
        _;
    }

    function checkDAO(uint256 projectNumber, uint256 serviceNumber, uint256 numMilestones, address  _from) internal view returns (bool) {
        mapping(uint256 => milestone) storage currService = servicesMilestones[projectNumber][serviceNumber];
        bool check = false;
        for (uint8 i = 0; i < numMilestones; i++) {
            milestone storage currMilestone = currService[i];
            if (currMilestone.serviceProvider == _from) {
                check = true;
            }
        }
        return check;
    }

/*
    Setter Functions
*/
    function setState(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, States.MilestoneStatus state) internal {
        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].status = state;
    }

    function getState(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint) {
        return uint(servicesMilestones[projectNumber][serviceNumber][milestoneNumber].status);
    }

/*
    CUD Milestones
*/

    /*
        Milestone - Create
    */

    function createMilestone(uint256 projectNumber, uint256 serviceNumber, string memory title, string memory description, uint256 price, address  _from) external 
        requiredString(title)
        requiredString(description)
    {
        require(token.checkBalance(_from) >= price , "You do not have enough tokens to create this milestone.");
        // uint256 milestoneNum = numMilestoneTracker[projectNumber][serviceNumber];
        milestone storage newMilestone = servicesMilestones[projectNumber][serviceNumber][milestoneNum];
        newMilestone.projectNumber = projectNumber;
        newMilestone.serviceNumber = serviceNumber;
        newMilestone.milestoneNumber = milestoneNum;
        newMilestone.title = title;
        newMilestone.description = description;
        newMilestone.exist = true;
        newMilestone.status = States.MilestoneStatus.created;
        newMilestone.price = price;
        newMilestone.serviceRequester = _from;  

        token.transferToEscrow(_from, price);

        emit milestoneCreated(projectNumber, serviceNumber, milestoneNum, title, description, price);

        milestoneTotal++;
        milestoneNum++;
        // numMilestoneTracker[projectNumber][serviceNumber]++;

    }

    /*
        Milestone - Update
    */

    function updateMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description) external 
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
        check service requester done in service
    */ 

    function deleteMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external 

        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.created)
    {
        uint256 price = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].price;
        require(token.checkFrozen(tx.origin) >= price, "The Escrow has been breached. It does not have enough funds");

        servicesMilestones[projectNumber][serviceNumber][milestoneNumber].exist = false; 

        milestoneTotal--;
        setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.terminated);
        emit milestoneDeleted(projectNumber, serviceNumber, milestoneNumber);

        //transfer price back to requester 
        address  requester = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceRequester; 

        token.transferFromEscrow(requester, requester, price);
    }

    /*
        Milestone - Accept
    */
    
    function acceptMilestone(uint256 projectNumber, uint256 serviceNumber, address provider) external
    {
        // uint256 milestoneNum = numMilestoneTracker[projectNumber][serviceNumber];
        // Accepts Service Contract, so all the Milestones are set to approved (locked in)
        for (uint i = 0; i < milestoneNum; i++){
            if(servicesMilestones[projectNumber][serviceNumber][i].status != States.MilestoneStatus.created ||
            servicesMilestones[projectNumber][serviceNumber][i].exist == false){ 
                continue; 
            }
            servicesMilestones[projectNumber][serviceNumber][i].serviceProvider = provider; 
            setState(projectNumber, serviceNumber, i, States.MilestoneStatus.approved);
            startNextMilestone(projectNumber, serviceNumber);
        }
    }

    /*
        Milestone - Start
    */

    function startNextMilestone(uint256 projectNumber, uint256 serviceNumber) internal {
        for (uint i = 0; i < milestoneNum; i++){
            if(
            servicesMilestones[projectNumber][serviceNumber][i].status == States.MilestoneStatus.approved &&
            servicesMilestones[projectNumber][serviceNumber][i].exist)
            { 
                setState(projectNumber, serviceNumber, i, States.MilestoneStatus.started);
                return;
            }
        }
    }
    /*
        Milestone - Complete
        -- service provider
    */
    function completeMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.started) // Must work on milestone in order
    {
        setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.completed);
        startNextMilestone(projectNumber, serviceNumber);
    }

    
    /*
        Milestone - Verify milestone
    */
    function verifyMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.completed) 
    {
        setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.verified);

        //MAKE PAYment of price from escrow wallet to service provider 
        address requester = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceRequester;
        address provider = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceProvider;
        uint256 price = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].price; 
  
        token.transferFromEscrow(requester, provider, price);
    }

/*

    Conflict functions

*/

    /*
        Conflict - Create
    */ 
    
    function createConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, string memory title, string memory description,  uint256 totalVoters) external 
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.completed)
    {
        
        address provider = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceProvider;
        address requester = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceRequester;

        conflict.createConflict(projectNumber,serviceNumber,milestoneNumber,title,description,requester,provider,totalVoters);

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
        Checks DAO here.
    */

    function startVote(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, uint256 numMilestones, address  _from) external
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.conflict)
    {   
        // require(checkDAO(projectNumber,serviceNumber,numMilestones,_from),"Not a valid DAO Member");
        conflict.startVote(projectNumber, serviceNumber, milestoneNumber);
    }
    
    /*
        Conflict - Vote
        Check DAO here.
    */

    function voteConflict(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, uint256 numMilestones, address _from, uint8 vote) external 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
        atState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.conflict)
    {
        // require(checkDAO(projectNumber,serviceNumber,numMilestones,_from),"Not a valid DAO Member");
        conflict.voteConflict(projectNumber,serviceNumber,milestoneNumber,_from,vote);

    }

    /*
        Conflict - Resolve payments
    */

    function resolveConflictPayment(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) external
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)
    {
        uint result = conflict.getResults(projectNumber, serviceNumber, milestoneNumber);
        require( result == 1 || result == 2, "There is no result to this conflict");
        address  provider = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceProvider;
        address  requester = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceRequester;
        uint256 price = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].price; 

        if (result == 2) {
            //service provider wins
            token.transferFromEscrow(requester, provider, price);
            setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.verified);
        } else {
            //split 50-50
            uint256 split_price = price.div(2);
            token.transferFromEscrow(requester, provider, split_price); 
            token.transferFromEscrow(requester, requester, split_price);
            setState(projectNumber, serviceNumber, milestoneNumber, States.MilestoneStatus.terminated);
            // what can we do about the rest of the tokens that are still in the escrow?
        }
    }

/*

    Review

*/

    /*
        Review - Review milestone
    */
    function reviewMilestone(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber, address  _from, string memory review_input, uint star_rating) public 
        isValidMilestone(projectNumber, serviceNumber, milestoneNumber)

    {
        address  milestoneServiceProvider = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceProvider;
        address  milestoneServiceRequester = servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceRequester;
        require(milestoneServiceProvider == _from || milestoneServiceRequester == _from , " Invalid");
        require(servicesMilestones[projectNumber][serviceNumber][milestoneNumber].status == States.MilestoneStatus.verified || servicesMilestones[projectNumber][serviceNumber][milestoneNumber].status == States.MilestoneStatus.terminated, "The milestone is not yet completed");

        if (milestoneServiceProvider == _from) {
            review.createReview(projectNumber,serviceNumber,milestoneNumber,_from,milestoneServiceRequester,review_input,States.Role.serviceRequester,star_rating);
        } else {
            review.createReview(projectNumber,serviceNumber,milestoneNumber,_from,milestoneServiceProvider,review_input,States.Role.serviceProvider,star_rating);
        }
    }

/*
    Getter Helper Functions
*/

    function getResults(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint) {
        return conflict.getResults(projectNumber,serviceNumber,milestoneNumber);

        //If contractor wins, pay contractor full price. If contractor loses, pay contracto half price and pay service requester half price. 
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

    function getMilestonePrice(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint256) {
        return servicesMilestones[projectNumber][serviceNumber][milestoneNumber].price;
    }

    function getVotesforProvider(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (uint256) {
        return conflict.getVotesforProvider(projectNumber,serviceNumber,milestoneNumber);
    }

    // Star Rating getters
    function getAvgServiceProviderStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        return review.getAvgServiceProviderStarRating(projectNumber,serviceNumber);
    }

    // Star Rating getters
    function getAvgServiceRequesterStarRating(uint256 projectNumber, uint256 serviceNumber) public view returns (uint256) {
        return review.getAvgServiceRequesterStarRating(projectNumber,serviceNumber);
    }

    // Get Service Requester
    function getServiceRequester(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (address) {
        return servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceRequester;
    }

    // Get Service Provider
    function getServiceProvider(uint256 projectNumber, uint256 serviceNumber, uint256 milestoneNumber) public view returns (address) {
        return servicesMilestones[projectNumber][serviceNumber][milestoneNumber].serviceProvider;
    }

}
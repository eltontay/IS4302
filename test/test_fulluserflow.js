const _deploy_contracts = require("../migrations/2_deploy_contract");
const truffleAssert = require("truffle-assertions");
const { expectEvent } = require('@openzeppelin/test-helpers');
var assert = require("assert");
const { create } = require("domain");
const { profile } = require("console");

var Profile = artifacts.require("Profile");
var Service = artifacts.require("Service");
var Blocktractor = artifacts.require("Blocktractor");
var Milestone = artifacts.require("Milestone");
var Conflict = artifacts.require("Conflict");
var Project = artifacts.require("Project");
var Review = artifacts.require("Review");
var Token = artifacts.require("Token");

contract("TestUserFlow", function (accounts) {
  let blocktractorInstance;
  const projectOwner = accounts[0];
  const serviceProvider1 = accounts[1];
  const serviceProvider2 = accounts[2];

  before(async () => {
    profileInstance = await Profile.deployed();
    reviewInstance = await Review.deployed();
    conflictInstance = await Conflict.deployed();
    tokenInstance = await Token.deployed();
    milestoneInstance = await Milestone.deployed();
    serviceInstance = await Service.deployed();
    projectInstance = await Project.deployed();
    blocktractorInstance = await Blocktractor.deployed();
  });

  it("Project Owner & Service Providers - Creating Profiles", async () => {
    let projectOwnerProfile = await blocktractorInstance.createProfile(
      "projectowner",
      "123456789",
      {
        from: projectOwner,
      }
    );

    assert.equal(
      await profileInstance.checkValidProfile({ from: projectOwner }), true
    );
    await expectEvent.inTransaction(projectOwnerProfile.tx, Profile, 'profileCreated', {name:"projectowner", owner:projectOwner});

    let serviceProvider1Profile = await blocktractorInstance.createProfile(
      "serviceprovider1",
      "123456789",
      {
        from: serviceProvider1,
      }
    );

    assert.equal(
      await profileInstance.checkValidProfile({ from: serviceProvider1 }), true
    );
    await expectEvent.inTransaction(serviceProvider1Profile.tx, Profile, 'profileCreated', {name:"serviceprovider1", owner:serviceProvider1});


    let serviceProvider2Profile = await blocktractorInstance.createProfile(
      "serviceprovider2",
      "123456789",
      {
        from: serviceProvider2,
      }
    );

    assert.equal(
      await profileInstance.checkValidProfile({ from: serviceProvider2 }), true
    );
    await expectEvent.inTransaction(serviceProvider2Profile.tx, Profile, 'profileCreated', {name:"serviceprovider2", owner:serviceProvider2});

  });


  it("Project Owner - Create Project", async () => {
    let createProject = await blocktractorInstance.createProject(
      "Launching an NFT",
      "This NFT project will become the next big thing.",
      {
        from: projectOwner,
      }
    );
       
    await expectEvent.inTransaction(createProject.tx, Project, 'projectCreated', 
    {
      projectNumber: '0',
      projectOwner:projectOwner, title:"Launching an NFT"
    });

  });


  it("Project Owner - Create Services", async () => {
    let createService1 = await blocktractorInstance.createService(
      0,
      "NFT Design",
      "Need an artist to design the artworks",
      {
        from: projectOwner,
      }
    );
    await expectEvent.inTransaction(createService1.tx, Service, 'serviceCreated', 
    {
      projectNumber: '0',
      serviceNumber:'0',
      title:"NFT Design"
    });


    let createService2 = await blocktractorInstance.createService(
      0,
      "Smart Contract Development",
      "Need a Smart Contract develop to develop smart contracts",
      {
        from: projectOwner,
      }
    );
    await expectEvent.inTransaction(createService2.tx, Service, 'serviceCreated', 
    {
      projectNumber: '0',
      serviceNumber:'1',
      title:"Smart Contract Development"
    });
  });


  it("Project Owner - Creates Tokens and Approve Blocktractor to move tokens", async () => {
    await tokenInstance.getCredit(
      {
        from: projectOwner,
        value: 2000000000000000000,
      }
    );
    assert.equal( await tokenInstance.checkBalance(projectOwner, { from: projectOwner }), 200 );

    await tokenInstance.approveContractFunds(
      100,
      {
        from: projectOwner,
      }
    );
    assert.equal( await tokenInstance.getApproved(projectOwner, projectOwner, {from: projectOwner}), 100);
  });


  it("Project Owner - Create Milestones", async () => {
    let createMilestone1 = await blocktractorInstance.createMilestone(
      0,
      0,
      "Artwork Design",
      "The artwork has to be of a giraffe",
      25,
      {
        from: projectOwner,
      }
    );
    await expectEvent.inTransaction(createMilestone1.tx, Milestone, 'milestoneCreated', 
    {
      projectNumber: '0',
      serviceNumber:'0',
      milestoneNumber:'0',
      title:"Artwork Design",
      price:"25"
    });
    assert.equal( await tokenInstance.checkFrozen(projectOwner, {from: projectOwner}), 25);
    assert.equal( await tokenInstance.checkBalance(projectOwner, { from: projectOwner }), 200 );


    let createMilestone2 = await blocktractorInstance.createMilestone(
      0,
      1,
      "Writing the smart contract",
      "The smart contract must be logic",
      25,
      {
        from: projectOwner,
      }
    );
    await expectEvent.inTransaction(createMilestone2.tx, Milestone, 'milestoneCreated', 
    {
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'1',
      title:"Writing the smart contract",
      price:'25'
    });
    assert.equal( await tokenInstance.checkFrozen(projectOwner, {from: projectOwner}), 50);


    let createMilestone3 = await blocktractorInstance.createMilestone(
      0,
      1,
      "Testing the smart contract",
      "The smart contract must pass all test cases",
      25,
      {
        from: projectOwner,
      }
    );
    await expectEvent.inTransaction(createMilestone3.tx, Milestone, 'milestoneCreated', 
    {      
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'2',
      title:"Testing the smart contract",
      price:'25'
    });
    assert.equal( await tokenInstance.checkFrozen(projectOwner, {from: projectOwner}), 75);

    let createMilestone4 = await blocktractorInstance.createMilestone(
      0,
      1,
      "Deploying the smart contract",
      "The smart contract must be deployed onto the etherum network",
      25,
      {
        from: projectOwner,
      }
    );
    await expectEvent.inTransaction(createMilestone4.tx, Milestone, 'milestoneCreated', 
    {
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'3',
      title:"Deploying the smart contract",
      price:'25'
    });
    assert.equal( await tokenInstance.checkFrozen(projectOwner, {from: projectOwner}), 100);
  });


  it("Service Provider - Take Service Requests && Project Owner - Accept Service Requests", async () => {
    // For Service 1: NFT Design
    await blocktractorInstance.takeServiceRequest(
      0, // Project Number
      0, // Service Number
      {
        from: serviceProvider1,
      }
    );
    assert.equal( await serviceInstance.getState(0,0, {from: serviceProvider1}), 1); // state pending
    assert.equal( await serviceInstance.getServiceProvider(0,0, {from: serviceProvider1}), serviceProvider1);

    await blocktractorInstance.acceptServiceRequest(
      0, // Project Number
      0, // Service Number
      {
        from: projectOwner,
      }
    );
    assert.equal( await serviceInstance.getState(0,0, {from: serviceProvider1}), 2); // state accepted
    assert.equal( await milestoneInstance.getServiceProvider(0,0,0, {from: serviceProvider1}), serviceProvider1);

    // For Service 2: Smart Contract Development
    await blocktractorInstance.takeServiceRequest(
      0, // Project Number
      1, // Service Number
      {
        from: serviceProvider2,
      }
    );
    assert.equal( await serviceInstance.getState(0,1, {from: serviceProvider1}), 1); // state pending
    assert.equal( await serviceInstance.getServiceProvider(0,1, {from: serviceProvider2}), serviceProvider2);

    await blocktractorInstance.acceptServiceRequest(
      0, // Project Number
      1, // Service Number
      {
        from: projectOwner,
      }
    );
    assert.equal( await serviceInstance.getState(0,1, {from: serviceProvider2}), 2); // state accepted
    assert.equal( await milestoneInstance.getServiceProvider(0,1,1, {from: serviceProvider2}), serviceProvider2);

  });


  it("Service Provider1 - Complete Milestone && Project Owner - Verifies && Payment is released", async () => {
    await blocktractorInstance.completeMilestone(
      0,
      0,
      0,
      {
        from: serviceProvider1,
      }
    );
    assert.equal( await milestoneInstance.getState(0,0,0, {from: serviceProvider1}), 4); //completed

    await blocktractorInstance.verifyMilestone(
      0, 
      0, 
      0, 
      {
        from: projectOwner,
      }
    );    
    assert.equal( await milestoneInstance.getState(0,0,0, {from: serviceProvider1}), 5); //verified      
    assert.equal( await tokenInstance.checkBalance(projectOwner, { from: projectOwner }), 175 ); // tokens left in owners wallet after paying
    assert.equal( await tokenInstance.checkFrozen(projectOwner, { from: projectOwner }), 75 ); // amount of frozen tokens
    assert.equal( await tokenInstance.getApproved(projectOwner, projectOwner, { from: projectOwner }), 75 ); //ensure that escrow can shift lesser tokens now
    assert.equal( await tokenInstance.checkBalance(serviceProvider1, { from: projectOwner }), 25 ); // tokens in providers wallet after finishing
    
  });


  it("Service Provider1 - Leaves a review && Project Owner - Leaves a review", async () => {
    let reviewProjectOwner = await blocktractorInstance.reviewMilestone(
      0,
      0,
      0,
      "The project owner is really good and clear with his instructions.",
      5, 
      {
        from: serviceProvider1,
      }
    );
    
    await expectEvent.inTransaction(reviewProjectOwner.tx, Review, 'reviewCreated', 
    {
      projectNumber: '0',
      serviceNumber:'0',
      milestoneNumber:'0',
      reviewee:projectOwner,
      reviewer:serviceProvider1, 
      role:"1",
      review_input:"The project owner is really good and clear with his instructions.", 
      star_rating:"5"
    });


    let reviewServiceProvider1 = await blocktractorInstance.reviewMilestone(
      0,
      0,
      0,
      "The service provider is very talent and I am happy with my artwork.",
      5, // Star input
      {
        from: projectOwner,
      }
    );
    await expectEvent.inTransaction(reviewServiceProvider1.tx, Review, 'reviewCreated', 
    {
      projectNumber: '0',
      serviceNumber:'0',
      milestoneNumber:'0',
      reviewee:serviceProvider1,
      reviewer:projectOwner, 
      role:"0",
      review_input:"The service provider is very talent and I am happy with my artwork.", 
      star_rating:"5"
    });
  });


  it("Service Provider1 - Complete Service Request for Service 0: NFT Design (only has 1 milestone)", async () => {
    await blocktractorInstance.completeServiceRequest(
      0,
      0,
      {
        from: serviceProvider1,
      }
    );    
    assert.equal( await serviceInstance.getState(0,0, {from: serviceProvider1}), 3); //completed
  });


  it("Service Provider2 - Completes Milestone 1 for Service 2 && Project Owner - Creates a Conflict & Starts Voting", async () => {
    await blocktractorInstance.completeMilestone(
      0,
      1,
      1,
      {
        from: serviceProvider2,
      }
    );
    let createConflict1 = await blocktractorInstance.createConflict(
      0,
      1,
      1,
      "Conflict for Milestone 1: Writing a smart contract",
      "The smart contract is did not fulfill its requirements",
      {
        from: projectOwner,
      }
    );
    
    await expectEvent.inTransaction(createConflict1.tx, Conflict, 'conflictCreated', 
    {
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'1',
      serviceRequester:projectOwner,
      serviceProvider:serviceProvider2,
      totalVoters:'1',
    });    
    assert.equal( await milestoneInstance.getState(0,1,1, {from: projectOwner}), 6); //conflict

    await blocktractorInstance.startVote(0, 1, 1, {
      from: projectOwner,
    });
    
    assert.equal( await conflictInstance.getState(0,1,1, {from: projectOwner}), 1); //conflict
  });


  it("Service Provider 1 - Votes on Conflict and votes for Service Provider 2 (Since he is the only one voting, Result is out)", async () => {
    let voteConflict1 = await blocktractorInstance.voteConflict(
      0,
      1,
      1,
      2, // Vote 2 for service provider
      {
        from: serviceProvider1,
      }
    );
    await expectEvent.inTransaction(voteConflict1.tx, Conflict, 'conflictVoted', 
    {      
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'1',
      voter: serviceProvider1,
      vote:'2'
    }); 
    await expectEvent.inTransaction(voteConflict1.tx, Conflict, 'conflictResult', 
    {      
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'1',
      result:'2'
    });      
    assert.equal( await conflictInstance.getState(0,1,1, {from: projectOwner}), 2); //completed

  });


  it("Project Owner - Resolved Conflict Payment and Service Provider 2 gets fully paid.", async () => {
    await blocktractorInstance.resolveConflictPayment(
      0,
      1,
      1,
      {
        from: projectOwner,
      }
    );
    
    assert.equal( await milestoneInstance.getState(0,1,1, {from: projectOwner}), 5); //verified

    // Asserting if the ethers for serviceProvider is released
    assert.equal( await tokenInstance.checkBalance(serviceProvider2, { from: serviceProvider2 }), 25);
    assert.equal( await tokenInstance.checkBalance(projectOwner, { from: projectOwner }), 150 ); // tokens left in owners wallet after paying
    assert.equal( await tokenInstance.checkFrozen(projectOwner, { from: projectOwner }), 50 ); // amount of frozen tokens
    assert.equal( await tokenInstance.getApproved(projectOwner, projectOwner, { from: projectOwner }), 50 ); //ensure that escrow can shift lesser tokens now    
  });


  it("Service Provider2 - Leaves a review for Milestone 1 since Milestone is resolved && Project Owner - Leaves a review", async () => {
    let reviewProjectOwner = await blocktractorInstance.reviewMilestone(
      0,
      1,
      1,
      "The project owner raised a conflict on me but the voters all voted in my favour",
      2, 
      {
        from: serviceProvider2,
      }
    );
    await expectEvent.inTransaction(reviewProjectOwner.tx, Review, 'reviewCreated', 
    {
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'1',
      reviewee:projectOwner,
      reviewer:serviceProvider2, 
      role:"1",
      review_input:"The project owner raised a conflict on me but the voters all voted in my favour", 
      star_rating:"2"
    });

    let reviewServiceProvider2 = await blocktractorInstance.reviewMilestone(
      0,
      1,
      1,
      "The service provider did not do good work but all the voters voted in his favour",
      1, // Star input
      {
        from: projectOwner,
      }
    );
    await expectEvent.inTransaction(reviewServiceProvider2.tx, Review, 'reviewCreated', 
    {
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'1',
      reviewee:serviceProvider2,
      reviewer:projectOwner, 
      role:"0",
      review_input:"The service provider did not do good work but all the voters voted in his favour", 
      star_rating:"1"
    });
  });


  it("Service Provider 2 - Continue to work on next milestone since the conflict resolved in his favour && Project Owner - Raises another conflict & Starts Voting", async () => {
    await blocktractorInstance.completeMilestone(
      0,
      1,
      2,
      {
        from: serviceProvider2,
      }
    );
    let createConflict2 = await blocktractorInstance.createConflict(
      0,
      1,
      2,
      "Conflict for Milestone 2: Testing the smart contract",
      "The smart contract did not pass all test cases",
      {
        from: projectOwner,
      }
    );

    await expectEvent.inTransaction(createConflict2.tx, Conflict, 'conflictCreated', 
    {
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'2',
      serviceRequester:projectOwner,
      serviceProvider:serviceProvider2,
      totalVoters:'1',
    });    
    assert.equal( await milestoneInstance.getState(0,1,2, {from: projectOwner}), 6); //conflict

    await blocktractorInstance.startVote(0, 1, 2, {
      from: projectOwner,
    });
    
    assert.equal( await conflictInstance.getState(0,1,2, {from: projectOwner}), 1); //conflict
  });


  it("Service Provider 1 - Votes on Conflict and votes for Project Owner this time (Since he is the only one voting, Conflict is Resolved.)", async () => {
    let voteConflict1 = await blocktractorInstance.voteConflict(
      0,
      1,
      2,
      1, // Vote 2 for service requester
      {
        from: serviceProvider1,
      }
    );
    await expectEvent.inTransaction(voteConflict1.tx, Conflict, 'conflictVoted', 
    {      
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'2',
      voter: serviceProvider1,
      vote:'1'
    }); 
    await expectEvent.inTransaction(voteConflict1.tx, Conflict, 'conflictResult', 
    {      
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'2',
      result:'1'
    });      
    assert.equal( await conflictInstance.getState(0,1,2, {from: projectOwner}), 2); //completed
  });


  it("Project Owner - Resolved Conflict Payment each party gets 50%", async () => {
    await blocktractorInstance.resolveConflictPayment(
      0,
      1,
      2,
      {
        from: projectOwner,
      }
    );
    
    assert.equal( await milestoneInstance.getState(0,1,2, {from: projectOwner}), 7); //terminated

    // Asserting if the ethers for serviceProvider is released
    assert.equal( await tokenInstance.checkBalance(serviceProvider2, { from: serviceProvider2 }), 37);
    assert.equal( await tokenInstance.checkBalance(projectOwner, { from: projectOwner }), 138 ); // tokens left in owners wallet after paying
    assert.equal( await tokenInstance.checkFrozen(projectOwner, { from: projectOwner }), 26 ); // amount of frozen tokens
    assert.equal( await tokenInstance.getApproved(projectOwner, projectOwner, { from: projectOwner }), 26 ); //ensure that escrow can shift lesser tokens now    
  });

  it("Service Provider2 - Leaves a review for Milestone 2 after Milestone is complete && Project Owner - Leaves a review", async () => {
    let reviewProjectOwner = await blocktractorInstance.reviewMilestone(
      0,
      1,
      2,
      "The project owner raised 2 conflict on me. I'm sure he has something personal against me. Beware of him.",
      1, // Star input
      {
        from: serviceProvider2,
      }
    );
    
    await expectEvent.inTransaction(reviewProjectOwner.tx, Review, 'reviewCreated', 
    {
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'2',
      reviewee:projectOwner,
      reviewer:serviceProvider2, 
      role:"1",
      review_input:"The project owner raised 2 conflict on me. I'm sure he has something personal against me. Beware of him.", 
      star_rating:"1"
    });

    let reviewServiceProvider2 = await blocktractorInstance.reviewMilestone(
      0,
      1,
      2,
      "The service provider did not do good work for 2 milestones. Beware of him.",
      1, // Star input
      {
        from: projectOwner,
      }
    );
    await expectEvent.inTransaction(reviewServiceProvider2.tx, Review, 'reviewCreated', 
    {
      projectNumber: '0',
      serviceNumber:'1',
      milestoneNumber:'2',
      reviewee:serviceProvider2,
      reviewer:projectOwner, 
      role:"0",
      review_input:"The service provider did not do good work for 2 milestones. Beware of him.", 
      star_rating:"1"
    });
  });
});

const _deploy_contracts = require("../migrations/2_deploy_contract");
const truffleAssert = require("truffle-assertions");
const {
  expectEvent, // Assertions for emitted events
} = require("@openzeppelin/test-helpers");
var assert = require("assert");
const { create } = require("domain");
const { profile } = require("console");

var Profile = artifacts.require('Profile');
var Service = artifacts.require("Service");
var Blocktractor = artifacts.require("Blocktractor");
var Milestone = artifacts.require("Milestone");
var Conflict = artifacts.require('Conflict');
var Project = artifacts.require("Project");
var Review = artifacts.require("Review");

contract("TestUserFlow", function (accounts) {
    let blocktractorInstance;
    const projectOwner = accounts[0];
    const serviceProvider1 = accounts[1];
    const serviceProvider2 = accounts[2];

    before(async () => {
        profileInstance = await Profile.deployed();
        reviewInstance = await Review.deployed();
        conflictInstance = await Conflict.deployed();
        milestoneInstance = await Milestone.deployed();
        serviceInstance = await Service.deployed();
        projectInstance = await Project.deployed();
        blocktractorInstance = await Blocktractor.deployed();
    });


    it("Project Owner & Service Providers - Creating Profiles", async () => {
        let projectOwnerProfile = await blocktractorInstance.createProfile(
            "Project Owner",
            "projectowner",
            '123456789',
            {
                from: projectOwner
            }    
        )

        assert.equal(await profileInstance.checkValidProfile({from: projectOwner}, true))

        let serviceProvider1Profile = await blocktractorInstance.createProfile(
            "Service Provider 1",
            "serviceprovider1",
            '123456789',
            {
                from: serviceProvider1
            }    
        )

        assert.equal(await profileInstance.checkValidProfile({from: serviceProvider1}, true))

        let serviceProvider2Profile = await blocktractorInstance.createProfile(
            "Service Provider 2",
            "serviceprovider2",
            '123456789',
            {
                from: serviceProvider2
            }    
        )

        assert.equal(await profileInstance.checkValidProfile({from: serviceProvider2}, true))

        
    })

    // Test that the service can be created
    it("Project Owner - Create Project", async () => {
        let createProject = await blocktractorInstance.createProject(
            "Launching an NFT",
            "This NFT project will become the next big thing.",
            {
                from: projectOwner,
            }
        );

        // Check that serviceCreated event is emitted
        /*
        serviceCreated is an event that belongs to Service.sol and not Blocktractor.sol,
        so it will not be picked up by eventEmitted as an emitted event by the Blocktractor contract
        Hence we use the openzeppelin testhelpers library to help us detect this event emission
        */
        //await expectEvent.inTransaction(createService1.tx, Service, 'serviceCreated');

        truffleAssert.eventEmitted(createProject, "serviceCreated", (ev) => {
            return ev.projectOwner == projectOwner && ev.title == "Launching an NFT" 
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
        truffleAssert.eventEmitted(createService1, "serviceCreated", (ev) => {
            return ev.projectOwner == projectOwner && ev.title == "NFT Design" 
        });

        let createService2 = await blocktractorInstance.createService(
            0,
            "Smart Contract Development",
            "Need a Smart Contract develop to develop smart contracts",
            {
                from: projectOwner,
            }
        );

        truffleAssert.eventEmitted(createService2, "serviceCreated", (ev) => {
            return ev.projectOwner == projectOwner && ev.title == "Smart Contract Development" 
        });
    });


    it("Project Owner - Create Milesontes", async () => {
        let createMilestone1 = await blocktractorInstance.createMilestone(
            0,
            0,
            "Artwork Design",
            "The artwork has to be of a giraffe",
            20,
            {
                from: projectOwner,
            }
        );
        truffleAssert.eventEmitted(createMilestone1, "milestoneCreated", (ev) => {
            return ev.projectNumber == 0 && ev.serviceNumber == 0 && ev.title == "Artwork Design"
        });

        let createMilestone2 = await blocktractorInstance.createMilestone(
            0,
            1,
            "Writing the smart contract",
            "The smart contract must be logic",
            20,
            {
                from: projectOwner,
            }
        );
        truffleAssert.eventEmitted(createMilestone3, "milestoneCreated", (ev) => {
            return ev.projectNumber == 0 && ev.serviceNumber == 1 && ev.title == "Writing the smart contract"
        });

        let createMilestone3 = await blocktractorInstance.createMilestone(
            0,
            1,
            "Testing the smart contract",
            "The smart contract must pass all test cases",
            20,
            {
                from: projectOwner,
            }
        );
        truffleAssert.eventEmitted(createMilestone3, "milestoneCreated", (ev) => {
            return ev.projectNumber == 0 && ev.serviceNumber == 0 && ev.title == "Testing the smart contract"
        });

        let createMilestone4 = await blocktractorInstance.createMilestone(
            0,
            1,
            "Deploying the smart contract",
            "The smart contract must be deployed onto the etherum network",
            20,
            {
                from: projectOwner,
            }
        );
        truffleAssert.eventEmitted(createMilestone4, "milestoneCreated", (ev) => {
            return ev.projectNumber == 0 && ev.serviceNumber == 0 && ev.title == "Deploying the smart contract"
        });

        // TODO: Would like to use a retrieve function here to ensure that the milestones created align
        
        // TODO: I NEED SOME WAY TO TEST PAYMENT FOR THE MILESTONE IS BEING MADE HERE
    });


    it("Service Provider - Take Service Requests && Project Owner - Accept Service Requests", async () => {

        // For Service 1: NFT Design
        let takeServiceRequest1 = await blocktractorInstance.takeServiceRequest(
            0,  // Project Number
            0,  // Service Number
            {
                from: serviceProvider1,
            }
        )
        // I NEED SOME WAY TO TEST THIS
        // const value = await blocktractorInstance.();
        // truffleAssert.eventEmitted(takeServiceRequest1, "")

        let acceptServiceRequest1 = await blocktractorInstance.acceptServiceRequest(
            0,  // Project Number
            0,  // Service Number
            {
                from: projectOwner,
            }
        )
        // I NEED SOME WAY TO TEST THIS
        // const value = await blocktractorInstance.();
        // truffleAssert.eventEmitted(takeServiceRequest1, "")      
        

        // For Service 2: Smart Contract Development
        let takeServiceRequest2 = await blocktractorInstance.takeServiceRequest(
            0,  // Project Number
            1,  // Service Number
            {
                from: serviceProvider2,
            }
        )
        // I NEED SOME WAY TO TEST THIS
        // const value = await blocktractorInstance.();
        // truffleAssert.eventEmitted(takeServiceRequest2, "")

        let acceptServiceRequest2 = await blocktractorInstance.acceptServiceRequest(
            0,  // Project Number
            1,  // Service Number
            {
                from: projectOwner,
            }
        )
        // I NEED SOME WAY TO TEST THIS
        // const value = await blocktractorInstance.();
        // truffleAssert.eventEmitted(takeServiceRequest2, "")    
    });


    it("Service Provider1 - Complete Milestone && Project Owner - Verifies && Payment is released", async () => {
        let completeMilestone1 = await blocktractorInstance.completeMilestone(
            0,
            0,
            0,
            {
                from: serviceProvider1
            }
        )
        // TODO: I NEED SOME WAY TO TEST THIS
        // const value = await blocktractorInstance.();
        // truffleAssert.eventEmitted(completeMilestone1, "")
        let verifyMilestone1 = await blocktractorInstance.verifyMilestone(
            0,
            0,
            0,
            {
                from: projectOwner
            }
        )
        // TODO: I NEED SOME WAY TO TEST THIS
        // const value = await blocktractorInstance.();
        // truffleAssert.eventEmitted(completeMilestone1, "")

        // TODO: I NEED SOME WAY TO TEST PAYMENT FOR THE MILESTONE IS BEING MADE FROM CONTRACT TO PROVIDER

    })


    it("Service Provider1 - Service is marked as completed since all milestones should be completed", async () => {
        let completeServiceRequest = blocktractorInstance.completeServiceRequest(
            0,
            0,
            {
                from: serviceProvider1
            }
        )
        // TODO: I NEED SOMETHING TO TEST THIS PLS
    });


    it("Service Provider1 - Leaves a review && Project Owner - Leaves a review", async () => {
        let reviewProjectOwner = await blocktractorInstance.reviewMilestone(
            0,
            0,
            0,
            serviceProvider1, // ???
            "The project owner is really good and clear with his instructions.",
            5, // Star input
            {
                from: serviceProvider1
            }
        )
        truffleAssert.eventEmitted(reviewProjectOwner, "reviewCreated", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 0 && 
                   ev.milestoneNumber == 0 && 
                   ev.reviewer == serviceProvider1 && 
                   ev.reviewee == projectOwner && 
                   ev.star_rating == 5
        })

        let reviewServiceProvider1 = await blocktractorInstance.reviewMilestone(
            0,
            0,
            0,
            projectOwner, // ???
            "The service provider is very talent and I am happy with my artwork.",
            5, // Star input
            {
                from: projectOwner
            }
        )
        truffleAssert.eventEmitted(reviewMilestone1, "reviewCreated", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 0 && 
                   ev.milestoneNumber == 0 && 
                   ev.reviewee == serviceProvider1 && 
                   ev.reviewer == projectOwner && 
                   ev.star_rating == 5
        })
    })


    it("Service Provider1 - Complete Service Request for Service 0: NFT Design (only has 1 milestone)", async () => {
        let completeServiceRequest1 = await blocktractorInstance.completeServiceRequest(
            0,
            0,
            {
                from: serviceProvider1
            }
        )
        // I NEED SOME WAY TO TEST THIS
        // const value = await blocktractorInstance.();
        // truffleAssert.eventEmitted(completeServiceRequest1, "")        
    })


    it("Service Provider2 - Completes Milestone 1 for Service 2 && Project Owner - Creates a Conflict & Starts Voting", async () => {
        let completeMilestone1 = await blocktractorInstance.completeMilestone(
            0,
            1,
            0,
            {
                from: serviceProvider2
            }
        )
        let createConflict1 = await blocktractorInstance.createConflict(
            0,
            1,
            0,
            "Conflict for Milestone 1: Writing a smart contract",
            "The smart contract is did not fulfill its requirements",
            projectOwner,
            serviceProvider2,
            1, // total voters ???
            {
                from: projectOwner
            }
        );
        
        truffleAssert.eventEmitted(createConflict1, "conflictCreated", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 0 && 
                   ev.serviceRequester == projectOwner && 
                   ev.serviceProvider == serviceProvider2 && 
                   ev.totalVoters == 1
        })

        let startVote1 = await blocktractorInstance.startVote(
            0, 
            1,
            0, 
            {
                from: projectOwner
            }
        )
        // I NEED SOME WAY TO TEST THIS
        // truffleAssert.eventEmitted(startVote1, "", (ev) => {})
    });


    it("Service Provider 1 - Votes on Conflict and votes for Service Provider 2 (Since he is the only one voting, Conflict is Resolved and Service Provider 2 gets full amount.)", async () => {
        var initialBlocktractorValue = await blocktractorInstance.getBalance({from: blocktractorInstance.address})
        let voteConflict1 = await blocktractorInstance.voteConflict(
            0,
            1,
            0,
            2, // Vote 2 for service provider
            {
                from: serviceProvider1
            }
        )

        truffleAssert.eventEmitted(voteConflict1, "conflictVoted", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 0 && 
                   ev.voter == serviceProvider1 && 
                   ev.vote == 2
        })

        truffleAssert.eventEmitted(voteConflict1, "conflictResult", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 0 && 
                   ev.result == 2
        })

        // Asserting if the ethers for serviceProvider is released 
        assert.equal(await blocktractorInstance.getBalance({from: serviceProvider2}), 20)
        assert.equal(await blocktractorInstance.getBalance({from: blocktractorInstance.address}), initialBlocktractorValue - 20);
    })


    it("Service Provider2 - Leaves a review for Milestone 1 since Milestone is resolved && Project Owner - Leaves a review", async () => {
        let reviewProjectOwner = await blocktractorInstance.reviewMilestone(
            0,
            1,
            0,
            serviceProvider2, // ???
            "The project owner raised a conflict on me but the voters all voted in my favour",
            2, // Star input
            {
                from: serviceProvider2
            }
        )
        truffleAssert.eventEmitted(reviewProjectOwner, "reviewCreated", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 0 && 
                   ev.reviewer == serviceProvider2 && 
                   ev.reviewee == projectOwner && 
                   ev.star_rating == 2
        })

        let reviewServiceProvider2 = await blocktractorInstance.reviewMilestone(
            0,
            1,
            0,
            projectOwner, // ???
            "The service provider did not do good work but all the voters voted in his favour",
            1, // Star input
            {
                from: projectOwner
            }
        )
        truffleAssert.eventEmitted(reviewMilestone1, "reviewCreated", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 0 && 
                   ev.reviewee == serviceProvider2 && 
                   ev.reviewer == projectOwner && 
                   ev.star_rating == 1
        })
    })


    it("Service Provider 2 - Continue to work on next milestone since the conflict resolved in his favour && Project Owner - Raises another conflict & Starts Voting", async () => {
        let completeMilestone2 = await blocktractorInstance.completeMilestone(
            0,
            1,
            1,
            {
                from: serviceProvider2
            }
        )
        let createConflict2 = await blocktractorInstance.createConflict(
            0,
            1,
            1,
            "Conflict for Milestone 2: Testing the smart contract",
            "The smart contract did not pass all test cases",
            projectOwner,
            serviceProvider2,
            1, // total voters ???
            {
                from: projectOwner
            }
        );
        
        truffleAssert.eventEmitted(createConflict2, "conflictCreated", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 1 && 
                   ev.serviceRequester == projectOwner && 
                   ev.serviceProvider == serviceProvider2 && 
                   ev.totalVoters == 1
        })

        let startVote2 = await blocktractorInstance.startVote(
            0, 
            1,
            1, 
            {
                from: projectOwner
            }
        )
        // I NEED SOME WAY TO TEST THIS
        // truffleAssert.eventEmitted(startVote2, "", (ev) => {})
    })


    it("Service Provider 1 - Votes on Conflict and votes for Project Owner this time (Since he is the only one voting, Conflict is Resolved and each party gets 50%.)", async () => {
        var initialBlocktractorValue = await blocktractorInstance.getBalance({from: blocktractorInstance.address})
        let voteConflict2 = await blocktractorInstance.voteConflict(
            0,
            1,
            1, // Milestone 2: Testing the smart contract
            1, // Vote 1 for Project Owner
            {
                from: serviceProvider1
            }
        )

        truffleAssert.eventEmitted(voteConflict2, "conflictVoted", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 1 && 
                   ev.voter == serviceProvider1 && 
                   ev.vote == 1
        })

        truffleAssert.eventEmitted(voteConflict2, "conflictResult", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 1 && 
                   ev.result == 1
        })

        // TODO: WOULD BE NICE IF I COULD RETRIEVE THE AMOUNT OF MONEY FOR MILESTONE 2 
        // Asserting if the ethers for serviceProvider is released 
        assert.equal(await blocktractorInstance.getBalance({from: serviceProvider2}), 10)
        assert.equal(await blocktractorInstance.getBalance({from: projectOwner}), 10)
        assert.equal(await blocktractorInstance.getBalance({from: blocktractorInstance.address}), initialBlocktractorValue - 20);

        // TODO: NEED TO CHECK HERE IF THE SERVICE PROVIDER IS NO LONGER ALLOWED TO CONTINUE (EITHER SERVICE IS SET TO DONE OR MILESTONE IDK)
    })

    it("Service Provider2 - Leaves a review for Milestone 2 after Milestone is complete && Project Owner - Leaves a review", async () => {
        let reviewProjectOwner = await blocktractorInstance.reviewMilestone(
            0,
            1,
            1,
            serviceProvider2, // ???
            "The project owner raised 2 conflict on me. I'm sure he has something personal against me. Beware of him.",
            1, // Star input
            {
                from: serviceProvider2
            }
        )
        truffleAssert.eventEmitted(reviewProjectOwner, "reviewCreated", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 1 && 
                   ev.reviewer == serviceProvider2 && 
                   ev.reviewee == projectOwner && 
                   ev.star_rating == 1
        })

        let reviewServiceProvider2 = await blocktractorInstance.reviewMilestone(
            0,
            1,
            1,
            projectOwner, // ???
            "The service provider did not do good work for 2 milestones. Beware of him.",
            1, // Star input
            {
                from: projectOwner
            }
        )
        truffleAssert.eventEmitted(reviewMilestone1, "reviewCreated", (ev) => {
            return ev.projectNumber == 0 && 
                   ev.serviceNumber == 1 && 
                   ev.milestoneNumber == 1 && 
                   ev.reviewee == serviceProvider2 && 
                   ev.reviewer == projectOwner && 
                   ev.star_rating == 1
        })
    })

});
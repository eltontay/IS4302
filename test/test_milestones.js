// const _deploy_contracts = require("../migrations/2_deploy_contract");
// const truffleAssert = require("truffle-assertions");
// const {
//   expectEvent, // Assertions for emitted events
// } = require("@openzeppelin/test-helpers");
// var assert = require("assert");
// const { create } = require("domain");

// // var Profile = artifacts.require('Profile');
// var Service = artifacts.require("Service");
// var Blocktractor = artifacts.require("Blocktractor");
// var Milestones = artifacts.require("Milestones");

// contract("Testmilestone", function (accounts) {
//   before(async () => {
//     // profileInstance = await Profile.deployed();
//     serviceInstance = await Service.deployed();
//     blocktractorInstance = await Blocktractor.deployed();
//     milestoneInstance = await Milestones.deployed();
//   });

//   /**
//    * Testing for Service Provider Add milestones functions
//    */
//   it("Successful Creation of Milestone", async () => {
//     let createMilestone = await milestoneInstance.createMilestone(
//       0,
//       "Providing Super Beautiful NFT Minting Services at Cheap Prices",
//       "I will help mint 10,000 NFTs for you for 1 Eth",
//       {
//         from: accounts[1],
//       }
//     );
//     assert.notStrictEqual(
//       createMilestone,
//       undefined,
//       "Failed to create milestone"
//     );
//     truffleAssert.eventEmitted(createMilestone, "milestoneCreated");
//   });
//   it("Successful Update of Milestone", async () => {
//     let updateMilestone = await milestoneInstance.updateMilestone(
//       0, //service numnber
//       0, //milestone 0
//       "Updated title",
//       "Updated description",
//       {
//         from: accounts[1],
//       }
//     );
//     truffleAssert.eventEmitted(updateMilestone, "milestoneUpdated");
//   });
//   it("Successful deletion of milestone", async () => {
//     let deleteMilestone = await milestoneInstance.deleteMilestone(0, 0);
//     truffleAssert.eventEmitted(deleteMilestone, "milestoneDeleted");
//   });
// });

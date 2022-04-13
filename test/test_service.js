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

// contract("TestService", function (accounts) {
//   before(async () => {
//     // profileInstance = await Profile.deployed();
//     serviceInstance = await Service.deployed();
//     blocktractorInstance = await Blocktractor.deployed();
//     milestoneInstance = await Milestones.deployed();
//   });
//   console.log("Deployed profile, service and blocktractor contracts");

//   /**
//    * Testing for Service Provider Add milestones functions
//    */
//   it("Successful Creation of Milestone", async () => {
//     //Account 1 creates a service
//     await serviceInstance.createService(
//       "Providing Super Beautiful NFT Minting Services at Cheap Prices",
//       "I will help mint 10,000 NFTs for you for 1 Eth",
//       100,
//       {
//         from: accounts[1],
//       }
//     );
//     //Use account 1 to create milestone
//     let milestoneCreation1 = await serviceInstance.addMilestone(
//       0, //service numnber 0 => account 1
//       "Milestone 0",
//       "Description of milestone 0",
//       {
//         from: accounts[1],
//       }
//     );
//     await serviceInstance.addMilestone(
//       0, //service numnber 0 => account 1
//       "Milestone 1",
//       "Description of milestone 1",
//       {
//         from: accounts[1],
//       }
//     );
//     assert.notStrictEqual(
//       milestoneCreation1,
//       undefined,
//       "Failed to create milestone"
//     );
//   });
//   it("Update milestone successfully", async () => {
//     let milestoneUpdate = await serviceInstance.updateMilestone(
//       0,
//       0,
//       "new milestone title",
//       "new milestone description",
//       {
//         from: accounts[1],
//       }
//     );
//     //check if title of milestone 0 is updated
//     let title = await milestoneInstance.getMilestoneTitle(0, 0);
//     assert.strictEqual(title, "new milestone title");
//   });
//   //delete milestones not working
//   // it("Delete milestone successfully", async () => {
//   //   let milestoneDelete = await serviceInstance.deleteMilestone(0, 0, {
//   //     from: accounts[1],
//   //   });
//   //   //check if title of milestone 0 is updated
//   //   let n = await milestoneInstance.getTotalNumMilestones(1);
//   //   // assert.strictEqual(title, "new milestone title");
//   // });
// });

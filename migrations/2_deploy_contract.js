const Profile = artifacts.require("Profile");
const Service = artifacts.require("Service");
const Blocktractor = artifacts.require("Blocktractor");
const Milestone = artifacts.require("Milestone");
const Project = artifacts.require("Project");
const Conflict = artifacts.require("Conflict");
const Review = artifacts.require("Review");
const Token = artifacts.require("Token");

module.exports = (deployer, network, accounts) => {
  deployer
    .deploy(Profile)
    .then(() => {
      return deployer.deploy(Token);
    })
    .then(() => {
      return deployer.deploy(Review);
    })
    .then(() => {
      return deployer.deploy(Conflict);
    })
    .then(() => {
      return deployer.deploy(Milestone, Conflict.address, Review.address, Token.address);
    })
    .then(() => {
      return deployer.deploy(Service, Milestone.address);
    })
    .then(() => {
      return deployer.deploy(Project, Service.address);
    })
    .then(() => {
      return deployer.deploy(Blocktractor, Profile.address, Project.address);
    });
};

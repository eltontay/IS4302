const Profile = artifacts.require("Profile");
const Review = artifacts.require("Review");
const Service = artifacts.require("Service");
const Blocktractor = artifacts.require("Blocktractor");
const Milestones = artifacts.require("Milestones");
const Token = artifacts.require("Token");
const Conflict = artifacts.require("Conflict");
const Project = artifacts.require("Project");
const ERC20 = artifacts.require("ERC20");

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
      return deployer.deploy(
        Milestones,
        Conflict.address,
        Review.address,
        Token.address
      );
    })
    .then(() => {
      return deployer.deploy(Service, Milestones.address);
    })
    .then(() => {
      return deployer.deploy(Project, Service.address);
    })
    .then(() => {
      return deployer.deploy(Blocktractor, Profile.address, Project.address);
    });
};

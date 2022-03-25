const Profile = artifacts.require("Profile");
const Service = artifacts.require("Service");
const Blocktractor = artifacts.require("Blocktractor");
const Milestones = artifacts.require("Milestones");

module.exports = (deployer, network, accounts) => {
  deployer
    .deploy(Profile)
    .then(() => {
      return deployer.deploy(Milestones);
    })
    .then(() => {
      return deployer.deploy(Service, Milestones.address);
    })
    .then(() => {
      return deployer.deploy(
        Blocktractor,
        Profile.address,
        Service.address,
        1000000
      );
    });
};

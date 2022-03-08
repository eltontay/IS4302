const Profile = artifacts.require('Profile');
const Service = artifacts.require('Service');
const Blocktractor = artifacts.require('Blocktractor');

module.exports = (deployer, network, accounts) => {
  deployer
    .deploy(Profile)
    .then(function () {
      return deployer.deploy(Service);
    })
    .then(function () {
      return deployer.deploy(
        Blocktractor,
        Profile.address,
        Service.address,
        10000
      );
    });
};

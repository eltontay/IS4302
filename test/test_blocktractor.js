const _deploy_contracts = require('../migrations/2_deploy_contract');
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

// var Profile = artifacts.require('Profile');
var Service = artifacts.require('Service');
var Blocktractor = artifacts.require('Blocktractor');

contract('TestBlocktractor', function (accounts) {
  before(async () => {
    // profileInstance = await Profile.deployed();
    serviceInstance = await Service.deployed();
    blocktractorInstance = await Blocktractor.deployed();
  });
  console.log('Deployed profile, service and blocktractor contracts');

  it('Create Service', async () => {
    let createService1 = await blocktractorInstance.createService(
      'Providing Super Beautiful NFT Minting Services at Cheap Prices',
      'I will help mint 10,000 NFTs for you for 1 Eth',
      100,
      {
        from: accounts[1],
      }
    );

    assert.notStrictEqual(
      createService1,
      undefined,
      'Failed to create service'
    );
  });
});

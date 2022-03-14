const _deploy_contracts = require('../migrations/2_deploy_contract');
const truffleAssert = require('truffle-assertions');
const {
  expectEvent,  // Assertions for emitted events
} = require('@openzeppelin/test-helpers');
var assert = require('assert');
const { create } = require('domain');

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

  // Test that the service can be created
  it('Create Service', async () => {
    let createService1 = await serviceInstance.createService(
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
    
    // Check that serviceCreated event is emitted
    /* 
      serviceCreated is an event that belongs to Service.sol and not Blocktractor.sol,
      so it will not be picked up by eventEmitted as an emitted event by the Blocktractor contract
      Hence we use the openzeppelin testhelpers library to help us detect this event emission
    */
    //await expectEvent.inTransaction(createService1.tx, Service, 'serviceCreated');

    truffleAssert.eventEmitted(createService1, 'serviceCreated');
    
  });

  // Test that if price is not included in service, error is raised
  it("Indicate Price", async () => {
    await truffleAssert.reverts(
      serviceInstance.createService(
        'Providing Super Beautiful NFT Minting Services at Cheap Prices',
        'I will help mint 10,000 NFTs for you for 1 Eth',
        0,
        {from: accounts[1]}
      ),
      "A Service Price must be specified"
    );
  });

  it("Only Service Provider can Delete", async() => {
    //console.log('service provider: %d', serviceInstance.services[0].serviceProvider)
    //console.log('address: ', blocktractorInstance)
    //console.log(await serviceInstance.getServiceDetails(0))
    await truffleAssert.reverts(
      serviceInstance.deleteService(0, {from: accounts[2]}),
      "Unauthorised access to service, only service provider can access"
    );
  });

  // Check if Service deletion is executed properly
  it("Delete Service", async () => {
    let deleteService1 = await(serviceInstance.deleteService(0, {from: accounts[1]}));
    
    assert.strictEqual(
      await serviceInstance.doesServiceExist(0),
      false,
      'Failed to soft delete service'
    );
    // Check that event is emitted
    //await expectEvent.inTransaction(deleteService1.tx, Service,"serviceDeleted")
    truffleAssert.eventEmitted(deleteService1, 'serviceDeleted');
  });



});




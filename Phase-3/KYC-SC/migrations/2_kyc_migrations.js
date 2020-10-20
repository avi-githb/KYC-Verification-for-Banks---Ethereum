var KYCContract = artifacts.require("KYCContract");

module.exports = function(deployer){
deployer.deploy(KYCContract);
};

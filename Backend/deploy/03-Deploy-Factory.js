const { network , ethers } = require("hardhat");

module.exports = async ({getNamedAccounts, deployments}) => {
    const {deployer} = await getNamedAccounts();
    const {deploy,log} = deployments;
    const chainid = network.config.chainId;
    log("deploy to the chainId " + chainid);

    const asset = await deployments.get("MockBTC");

    // args = [asset.address,100,ethers.getSigner()];
    const args = [];

    const Factory = await deploy("Factory", {
        args: args,
        from: deployer,
        log: true,
    });

    log(`The address of the deployed contract ${Factory.address}`);
    log("------------------------------------------------------------------------");

}

module.exports.tags = ["all", "Factory"];
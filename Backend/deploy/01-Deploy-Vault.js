const { network , ethers } = require("hardhat");

module.exports = async ({getNamedAccounts, deployments}) => {
    const {deployer} = await getNamedAccounts();
    const {deploy,log} = deployments;
    const chainid = network.config.chainId;
    log("deploy to the chainId " + chainid);

    const MockBTC = await deployments.get("MockBTC");

    args = [MockBTC.address];

    const Vault = await deploy("Vault", {
        args: args,
        from: deployer,
        log: true,
    });

    log(`The address of the deployed contract ${Vault.address}`);
    log("------------------------------------------------------------------------");

}

module.exports.tags = ["all", "Vault"];
import { ethers } from 'ethers';
import fs from 'fs';
import path from 'path';

/**
 * Deploy the given contract
 * @param {string} contractName name of the contract to deploy
 * @param {Array<any>} args list of constructor parameters
 * @param {Number} accountIndex account index from the exposed account
 * @return {Promise<ethers.Contract>} deployed contract
 */
export const deploy = async (contractName: string, args: Array<any>, accountIndex?: number): Promise<ethers.Contract> => {
  console.log(`Deploying ${contractName}`);

  // Path to the compiled contract JSON file
  const artifactsPath = path.resolve(__dirname, '..', 'artifacts', `${contractName}.json`);

  // Read the contract JSON file
  const metadata = JSON.parse(fs.readFileSync(artifactsPath, 'utf8'));

  // Connect to the Ethereum network
  const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545"); // Change URL if needed
  const signer = provider.getSigner(accountIndex || 0);

  // Create a factory for deploying instances of the contract
  const factory = new ethers.ContractFactory(metadata.abi, metadata.bytecode, signer);

  // Deploy the contract with the provided arguments
  const contract = await factory.deploy(...args);

  // Wait for the contract to be deployed
  await contract.deployed();

  console.log(`Contract deployed at address: ${contract.address}`);
  return contract;
};

// Example usage
(async () => {
  try {
    const result = await deploy('Hostel', []);
    console.log(`Address: ${result.address}`);
  } catch (e) {
    if (e instanceof Error) {
      console.error(e.message);
    } else {
      console.error('An unknown error occurred');
    }
  }
})();

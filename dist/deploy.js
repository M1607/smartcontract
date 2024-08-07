"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deploy = void 0;
const ethers_1 = require("ethers");
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
/**
 * Deploy the given contract
 * @param {string} contractName name of the contract to deploy
 * @param {Array<any>} args list of constructor parameters
 * @param {Number} accountIndex account index from the exposed account
 * @return {Promise<ethers.Contract>} deployed contract
 */
const deploy = (contractName, args, accountIndex) => __awaiter(void 0, void 0, void 0, function* () {
    console.log(`Deploying ${contractName}`);
    // Path to the compiled contract JSON file
    const artifactsPath = path_1.default.resolve(__dirname, '..', 'artifacts', `${contractName}.json`);
    // Read the contract JSON file
    const metadata = JSON.parse(fs_1.default.readFileSync(artifactsPath, 'utf8'));
    // Connect to the Ethereum network
    const provider = new ethers_1.ethers.providers.JsonRpcProvider("http://127.0.0.1:8545"); // Change URL if needed
    const signer = provider.getSigner(accountIndex || 0);
    // Create a factory for deploying instances of the contract
    const factory = new ethers_1.ethers.ContractFactory(metadata.abi, metadata.bytecode, signer);
    // Deploy the contract with the provided arguments
    const contract = yield factory.deploy(...args);
    // Wait for the contract to be deployed
    yield contract.deployed();
    console.log(`Contract deployed at address: ${contract.address}`);
    return contract;
});
exports.deploy = deploy;
// Example usage
(() => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const result = yield (0, exports.deploy)('Hostel', []);
        console.log(`Address: ${result.address}`);
    }
    catch (e) {
        if (e instanceof Error) {
            console.error(e.message);
        }
        else {
            console.error('An unknown error occurred');
        }
    }
}))();

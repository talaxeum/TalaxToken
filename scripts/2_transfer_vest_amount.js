const ethers = require("ethers");
const fullAbi = require("../build/contracts/TalaxToken3.json");

const api = "";
const privateKey = "";
const provider = new ethers.providers.InfuraProvider("homestead", api);
const wallet = new ethers.Wallet(privateKey, provider);

const contractAddress = "";

// const governance = new ethers.Contract(contractAddress, abi, provider);
const talax = new ethers.Contract(contractAddress, fullAbi["abi"], wallet);

const Vest = [
    { address: "0x0000000000000000000000000000000000000001", amount: ethers.utils.parseEther("482624736.0") }, //? Public Sale
    { address: "0x0000000000000000000000000000000000000002", amount: ethers.utils.parseEther("1206760623.0") }, //? Private Sale
    { address: "0x0000000000000000000000000000000000000003", amount: ethers.utils.parseEther("1069299630.0") }, //? Private Placement
    { address: "0x0000000000000000000000000000000000000004", amount: ethers.utils.parseEther("1050000000.0") }, //? Strategic Partner
    { address: "0x0000000000000000000000000000000000000004", amount: ethers.utils.parseEther("2100000000.0") }, //? Team & Project Contributor
    { address: "0x0000000000000000000000000000000000000004", amount: ethers.utils.parseEther("1209600000.0") }, //? Marketing
    { address: "0x0000000000000000000000000000000000000004", amount: ethers.utils.parseEther("2100000000.0") }, //? Staking Reward
    { address: "0x0000000000000000000000000000000000000004", amount: ethers.utils.parseEther("6300000000.0") }, //? Liquidity Reserve
    { address: "0x0000000000000000000000000000000000000004", amount: ethers.utils.parseEther("4978890000.0") }, //? DAO Project Launch Pool
];

const transferVest = async () => {
    // let name = await governance.name();
    // console.log(name);
    // const tx = await teamAndProjectContributorWhitelist.addMultiVesting(team_addresses(amount));

    for (const idx in Vest) {
        const tx = await talax.transfer(Vest[idx].address, Vest[idx].amount);
        const receipt = await tx.wait();
        console.log(receipt);
        console.log("======================================================");
    }
};

transferTGE();

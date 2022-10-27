const ethers = require("ethers");
const fullAbi = require("../build/contracts/TalaxToken3.json");

const api = "";
const privateKey = "";
const provider = new ethers.providers.InfuraProvider("homestead", api);
const wallet = new ethers.Wallet(privateKey, provider);

const contractAddress = "";

// const governance = new ethers.Contract(contractAddress, abi, provider);
const talax = new ethers.Contract(contractAddress, fullAbi["abi"], wallet);

const TGE = [
    { address: "0x0000000000000000000000000000000000000001", amount: ethers.utils.parseEther("120656184.0") }, //? Public Sale
    { address: "0x0000000000000000000000000000000000000002", amount: ethers.utils.parseEther("212957757.0") }, //? Private Sale
    { address: "0x0000000000000000000000000000000000000003", amount: ethers.utils.parseEther("118811070.0") }, //? Private Placement
    { address: "0x0000000000000000000000000000000000000004", amount: ethers.utils.parseEther("50400000.0") }, //? Marketing
];

const transferTGE = async () => {
    // let name = await governance.name();
    // console.log(name);
    // const tx = await teamAndProjectContributorWhitelist.addMultiVesting(team_addresses(amount));

    for (const idx in TGE) {
        const tx = await talax.transfer(TGE[idx].address, TGE[idx].amount);
        const receipt = await tx.wait();
        console.log(receipt);
        console.log("======================================================");
    }
};

transferTGE();

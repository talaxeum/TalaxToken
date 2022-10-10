const ethers = require("ethers");
const fullAbi = require("../build/contracts/TeamWhitelist.json");

const api = "";
const provider = new ethers.providers.InfuraProvider("homestead", api);

const contractAddress = "";

// const governance = new ethers.Contract(contractAddress, abi, provider);
const teamAndProjectContributorWhitelist = new ethers.Contract(contractAddress, fullAbi["abi"], provider);

const team_addresses = (amount) => {
    return [
        ["0x0000000000000000000000000000000000000001", amount / 3],
        ["0x0000000000000000000000000000000000000001", amount / 3],
        ["0x0000000000000000000000000000000000000001", amount / 3],
    ];
};

const insertTeamBeneficiaries = async (amount) => {
    let name = await governance.name();
    console.log(name);

    const tx = await teamAndProjectContributorWhitelist.addMultiVesting(team_addresses(amount));
};

insertTeamBeneficiaries(0);

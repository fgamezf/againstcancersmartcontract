const { ethers } = require("hardhat");

const main = async () => {
    const [owner, randomPerson] = await hre.ethers.getSigners();
    const waveContractFactory = await hre.ethers.getContractFactory('WavePortal');
    const waveContract = await waveContractFactory.deploy();
    await waveContract.deployed();

    console.log("Contract deployed to:", waveContract.address);
    console.log("Contract deployed by:", owner.address);

    let waveCount;
    waveCount = await waveContract.getTotalWaves();
    console.log(waveCount.toNumber());

    /**
   * Let's send a few waves!
   */
    let waveTxn = await waveContract.wave('A message!', { from: owner.address, value: ethers.utils.parseEther("" + 2)});
    await waveTxn.wait(); // Wait for the transaction to be mined

    waveTxn = await waveContract.connect(randomPerson).wave('Another message!',  { from: randomPerson.address, value:  ethers.utils.parseEther("" + 1)});
    await waveTxn.wait(); // Wait for the transaction to be mined

    let allWaves = await waveContract.getAllWaves();
    console.log(allWaves);

    let balance = await waveContract.getContractBalance();
    console.log("Balance = $d", balance / 1e18);

    let ownerBalance = await waveContract.provider.getBalance(owner.address);
    let randomPersonBalance = await waveContract.provider.getBalance(randomPerson.address);
    console.log("Owner Balance = $d", ownerBalance / 1e18);
    console.log("Random person Balance = $d", randomPersonBalance / 1e18);

    waveTxn = await waveContract.donate(randomPerson.address);
    await waveTxn.wait(); // Wait for the transaction to be mined

    balance = await waveContract.getContractBalance();
    console.log("Balance = $d", balance / 1e18);

    ownerBalance = await waveContract.provider.getBalance(owner.address);
    randomPersonBalance = await waveContract.provider.getBalance(randomPerson.address);
    console.log("Owner Balance = $d", ownerBalance / 1e18);
    console.log("Random person Balance = $d", randomPersonBalance / 1e18);

};
  
const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
};
  
runMain();
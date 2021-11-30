// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    address payable public owner;
    uint DONATED_PERCENTAGE = 90;
    uint OWNER_PERCENTAGE = 5;
    uint256 MIN_AMOUNT_TO_DONATE = 0 ether;

     /*
     * A little magic, Google what events are in Solidity!
     */
    event NewWave(address indexed from, uint256 timestamp, string message, uint256 amount);
    event NewDonation(address indexed to, uint256 timestamp, uint256 amount);

    /*
     * I created a struct here named Wave.
     * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
        uint256 amount; // The amount donated by user
    }

    /*
     * I declare a variable waves that lets me store an array of structs.
     * This is what lets me hold all the waves anyone ever sends to me!
     */
    Wave[] waves;

    constructor() {
        owner = payable(msg.sender);
        console.log("Yeah, second smart contract for my dapp");
    }

    function wave(string memory _message) public payable {

        require(msg.value >= MIN_AMOUNT_TO_DONATE, "Minimum ether required to wave");

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);
         /*
         * This is where I actually store the wave data in the array.
         */
        waves.push(Wave(msg.sender, _message, block.timestamp, msg.value));

        /*
         * I added some fanciness here, Google it and try to figure out what it is!
         * Let me know what you learn in #general-chill-chat
         */
        emit NewWave(msg.sender, block.timestamp, _message, msg.value);
       
    }

    /*
     * I added a function getAllWaves which will return the struct array, waves, to us.
     * This will make it easy to retrieve the waves from our website!
     */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        // Optional: Add this line if you want to see the contract print the value!
        // We'll also print it over in run.js as well.
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    /**
    * Get balance of the smart contract
    */
    function getContractBalance() public view returns (uint) {
      return address(this).balance;
    }

    /**
    * Get balance of the smart contract
    */
    function getContractBalanceInEther() public view returns (uint) {
      return getContractBalance() / 1e18;
    }

    function transfer(uint amount) private isOwner {
        require(address(this).balance >= amount);
        owner.transfer(amount);
    }

    /**
    * Donate cryptos in the following ways
    *  90% - to non lucrative organization
    *   5% - to owner to get GAS and make donations and to mantain front end app (Azure, AWS)
    *   5% - remains in the smart contract (contingency)
    */
    function donate(address payable to) public isOwner {
        uint256 amountDonated = address(this).balance * DONATED_PERCENTAGE / 100;
        uint256 amountForOwner = address(this).balance * OWNER_PERCENTAGE / 100;
        require(address(this).balance >= amountDonated);
        require(to != address(0));
        console.log("Amount to donate %d", amountDonated);
        to.transfer(amountDonated);

        console.log("Amount for owner %d", amountForOwner);
        transfer(amountForOwner);

        emit NewDonation(to, block.timestamp, amountDonated);
    }

    /*
    * Owner modifier
    */
    modifier isOwner() {
      require(msg.sender == owner);
      _;
    }

}
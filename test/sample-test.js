const { expect } = require("chai");
const { assert } = require("chai");
const { ethers } = require("hardhat");

describe("Tracelabs Smart Bank Contract", ()=>{
  let alice;
  let bob;
  let charlie;
  let tokens;
  let bank;
  //let bankInterface;

  before(async function(){
    [alice, bob, charlie] = await ethers.getSigners();
    const Tokens = await ethers.getContractFactory("XYZ", charlie);
    tokens = await Tokens.deploy(1000000000000);
    await tokens.deployed();

    const Bank = await ethers.getContractFactory("BankV2", charlie);
    bank = await Bank.deploy(tokens.address, 1, 10000);
    await bank.deployed()
    //bankInterface = await ethers.getContractAt("IERC20", tokens.address);
  })

  it("Should test that contracts deployed successfully", async function() {
    expect(await tokens.balanceOf(charlie.address)).to.equal(1000000000000);
    expect(await bank.timePeriodValue()).to.equal(86400);
  })

  it("Should validate that accounts have been funded", async function(){
    await tokens.connect(charlie).approve(alice.address, 100);
    await tokens.connect(charlie).approve(bob.address, 400);
    await tokens.connect(charlie).approve(tokens.address, 100000);

    await tokens.connect(charlie).transfer(alice.address, 100);
    await tokens.connect(charlie).transfer(bob.address, 400);
    await tokens.connect(charlie).transfer(tokens.address, 100000);
    
    expect(await tokens.balanceOf(alice.address)).to.equal(100);
    expect(await tokens.balanceOf(bob.address)).to.equal(400);
    expect(await tokens.balanceOf(tokens.address)).to.equal(100000);

  })

  it("Should allow funded users to deposit into the bank", async function(){
    await bank.connect(alice).deposit(100);
    expect(await bank.connect(alice).getStakedBalance()).to.equal(100);
  })

  it("Should time jump and allow for withdrawal of tokens", async function(){
    await ethers.provider.send("evm_increaseTime", [24 * 60* 60])
    await ethers.provider.send("evm_mine");

    await bank.connect(alice).withdraw(100)
    expect(await bank.connect(alice).getStakedBalance()).to.equal(0);
  })

  it("Should  for withdrawal of reward tokens", async function () {   
    const bal1 = await tokens.balanceOf(alice.address);
    console.log("Alice's Balance before withdrawal is: ", bal1.toString()); 
    const balance_before_withdrawal_of_rewards = bal1;
    //await tokens.approve(alice.address, 8000)
    await bank.connect(alice).withdrawReward();
    
    const balance_after_withdrawal_of_rewards = await tokens.balanceOf(alice.address);
    console.log(balance_after_withdrawal_of_rewards)
    assert(balance_after_withdrawal_of_rewards.toString() > balance_before_withdrawal_of_rewards.toString())
    
    console.log(await tokens.balanceOf(tokens.address))
  });

  

  
})
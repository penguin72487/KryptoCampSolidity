const { assert } = require("chai");

const testGaoDuckToken = artifacts.require("testGaoDuckToken");
const AMM = artifacts.require("AMM");

contract("AMM and testGaoDuckToken", (accounts) => {
  let amm, token;
  const owner = accounts[0];
  const user1 = accounts[1];
  const user2 = accounts[2];

  beforeEach(async () => {
    token = await testGaoDuckToken.new("testGaoDuckToken", "tGD");
    amm = await AMM.new(token.address);
  });

  it("should deploy contracts and mint tokens", async () => {
    assert.ok(token.address);
    assert.ok(amm.address);

    await token.mint(owner, 1000000);
    await token.mint(user1, 1000000);

    const ownerBalance = await token.balanceOf(owner);
    const user1Balance = await token.balanceOf(user1);

    assert.equal(ownerBalance.toString(), "1000000000000000000000000");
    assert.equal(user1Balance.toString(), "1000000000000000000000000");
  });

  it("should add liquidity", async () => {
    await token.approve(amm.address, "1000000000000000000000", { from: owner });

    await amm.addLiquidity("1000000000000000000000", { from: owner, value: web3.utils.toWei("1", "ether") });

    const ammReserve0 = await amm.reserve0();
    const ammReserve1 = await amm.reserve1();
    const ownerShares = await amm.balanceOf(owner);

    assert.equal(ammReserve0.toString(), web3.utils.toWei("1", "ether"));
    assert.equal(ammReserve1.toString(), "1000000000000000000000");
    assert.ok(ownerShares.toString() > 0);
  });

  it("should swap ETH for tokens", async () => {
    await token.approve(amm.address, "1000000000000000000000", { from: owner });
    await amm.addLiquidity("1000000000000000000000", { from: owner, value: web3.utils.toWei("1", "ether") });

    await amm.swap(web3.utils.toWei("0.1", "ether"), { from: user1, value: web3.utils.toWei("0.1", "ether") });

    const user1TokenBalance = await token.balanceOf(user1);
    const ammReserve0 = await amm.reserve0();
    const ammReserve1 = await amm.reserve1();

    assert.ok(user1TokenBalance.toString() > 0);
    assert.ok(ammReserve0.toString() > web3.utils.toWei("1", "ether"));
    assert.ok(ammReserve1.toString() < "1000000000000000000000");
  });

  it("should swap tokens for ETH", async () => {
    await token.approve(amm.address, "1000000000000000000000", { from: owner });
    await amm.addLiquidity("1000000000000000000000", { from: owner,value: web3.utils.toWei("1", "ether") });

    await token.approve(amm.address, "500000000000000000000", { from: user1 });
    await amm.swapTokenForETH("500000000000000000000", { from: user1 });
    
    const user1TokenBalance = await token.balanceOf(user1);
    const user1ETHBalance = await web3.eth.getBalance(user1);
    const ammReserve0 = await amm.reserve0();
    const ammReserve1 = await amm.reserve1();
    
    assert.ok(user1TokenBalance.toString() < "1000000000000000000000000");
    assert.ok(parseInt(user1ETHBalance) > web3.utils.toWei("100", "ether"));
    assert.ok(ammReserve0.toString() < web3.utils.toWei("1", "ether"));
    assert.ok(ammReserve1.toString() > "1000000000000000000000");
    });
    
    it("should remove liquidity", async () => {
    await token.approve(amm.address, "1000000000000000000000", { from: owner });
    await amm.addLiquidity("1000000000000000000000", { from: owner, value: web3.utils.toWei("1", "ether") });
    
    const ownerSharesBefore = await amm.balanceOf(owner);
    await amm.removeLiquidity(ownerSharesBefore.toString(), { from: owner });
    
    const ownerTokenBalance = await token.balanceOf(owner);
    const ownerETHBalance = await web3.eth.getBalance(owner);
    const ammReserve0 = await amm.reserve0();
    const ammReserve1 = await amm.reserve1();
    const ownerSharesAfter = await amm.balanceOf(owner);
    
    assert.ok(ownerTokenBalance.toString() > "1000000000000000000000000");
    assert.ok(parseInt(ownerETHBalance) > web3.utils.toWei("99", "ether"));
    assert.equal(ammReserve0.toString(), "0");
    assert.equal(ammReserve1.toString(), "0");
    assert.equal(ownerSharesAfter.toString(), "0");
    });
    });

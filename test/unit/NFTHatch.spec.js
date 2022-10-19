const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
let eggNFT = null;
let store = null;


describe("NFT store", function () {
  
  //do a beforeEAch deploying the contracts
  beforeEach(async function () {
      const [owner, addr1, addr2] = await ethers.getSigners();
      const eggFactory = await ethers.getContractFactory("EggNFT");
      eggNFT = await eggFactory.deploy();
      const StoreFactory = await ethers.getContractFactory("Store");
      store = await StoreFactory.deploy(eggNFT.address);
      await eggNFT.setStoreAddress(store.address);
  });

  
  //create a test to buy from store
  /*
  it("Should buy an egg from the store", async function () {
      const [owner, addr1, addr2] = await ethers.getSigners();
      await store.connect(addr1).buy({ value: ethers.utils.parseEther("1") });
      expect(await eggNFT.balanceOf(addr1.address)).to.equal(1);

      await expect(store.connect(addr1).buy({ value: ethers.utils.parseEther("1") }))
      .to.emit(store, "Buy");
  });*/


  //create a test to buy from store
  it("Get tokens URL", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    await store.connect(addr1).buy({ value: ethers.utils.parseEther("1") });
    let test = await eggNFT.tokenURI(1);

    console.log(test);

  });


  //create a test to buy eggNFT from the store
    
  /*
  it("Should buy an eggNFT from the store", async function () {
      const [owner, addr1, addr2] = await ethers.getSigners();

      let tokenFirstId = await eggNFT.connect(addr1).safeMint(addr1.address, 'xxxxxxx');
      let tokenSecondID = await eggNFT.connect(addr1).safeMint(addr1.address, 'xxxxxx1');

      expect(await eggNFT.balanceOf(addr1.address)).to.equal(2);

      let balance = await eggNFT.connect(addr1).balanceOf(addr1.address);
  });
  */

});

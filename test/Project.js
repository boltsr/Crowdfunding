const { expect } = require("chai");
const { BigNumber } = require("ethers");
const hre = require("hardhat");
const { ethers } = require("hardhat");
const { advanceTimeAndBlock } = require("../utils/blocktime");
describe("Project", function () {
  before(async () => {
    const Project = await hre.ethers.getContractFactory("Project");
    project = await Project.deploy();
    await project.deployed();
    const ProjectFactory = await hre.ethers.getContractFactory(
      "ProjectFactory"
    );
    projectFactory = await ProjectFactory.deploy(project.address);
    await projectFactory.deployed();
  });
  describe("Deployment", function () {
    it("Should set target", async function () {
      await (await projectFactory.createProject("1000", "1000")).wait();
      const projectList = await projectFactory.allProject();
      const projectContract = await project.attach(
        projectList[0] // The deployed contract address
      );
      const targetAmount = await projectContract.targetAmount();
      expect(BigNumber.from(targetAmount).toString()).to.equal("1000");
    });

    it("Should update project owner", async function () {
      const [owner] = await ethers.getSigners();
      await (await projectFactory.createProject("1000", "1000")).wait();
      const projectList = await projectFactory.allProject();
      const projectContract = await project.attach(
        projectList[0] // The deployed contract address
      );
      const manager = await projectContract.manager();
      expect(manager).to.equal(owner.address);
    });

    it("Should set the request", async function () {
      const [owner, otherAccount] = await ethers.getSigners();
      await projectFactory.connect(owner).createProject("1000", "1000");
      const projectList = await projectFactory.allProject();

      const projectContract = await project.attach(
        projectList[0] // The deployed contract address
      );
      await expect(
        projectContract
          .connect(otherAccount)
          .createRequest(
            "new",
            "0xB7180670fc3e7a4Ccd8fE4bcBEcAe2bEaA7d92E0",
            "10000"
          )
      ).to.be.revertedWith("Only manager can call this function");

      await projectContract
        .connect(owner)
        .createRequest(
          "new",
          "0xB7180670fc3e7a4Ccd8fE4bcBEcAe2bEaA7d92E0",
          "10000"
        );
      const numReq = await projectContract.numRequests();
      const requests = await projectContract.requests(0);
      expect(BigNumber.from(numReq).toString()).to.equal("1");
      expect(requests.description).to.equal("new");
      expect(requests.recipient).to.equal(
        "0xB7180670fc3e7a4Ccd8fE4bcBEcAe2bEaA7d92E0"
      );
      expect(BigNumber.from(requests.value).toString()).to.equal("10000");
      expect(requests.completed).to.equal(false);
    });
    it("Should show contract balance", async function () {
      // const [owner, other] = await ethers.getSigners();
      await (await projectFactory.createProject("1000", "1000")).wait();
      const projectList = await projectFactory.allProject();
      const projectContract = await project.attach(
        projectList[0] // The deployed contract address
      );
      const balance = await projectContract.getBalance();
      expect(BigNumber.from(balance).toString()).to.equal("0");
    });
    it("Should send ether to project", async function () {
      const [owner, other, third] = await ethers.getSigners();
      await (await projectFactory.createProject("1000", "1000")).wait();
      const projectList = await projectFactory.allProject();
      const projectContract = await project.attach(
        projectList[0] // The deployed contract address
      );
      await projectContract.connect(other).sendFunds({
        value: "10000000000000000",
      });
      await projectContract.connect(third).sendFunds({
        value: "1000000000000000",
      });

      const balance = await projectContract.getBalance();
      const raisedAmount = await projectContract.raisedAmount();
      const contributorAmount = await projectContract.fundContributors(
        other.address
      );
      const thirdAmount = await projectContract.fundContributors(third.address);

      expect(BigNumber.from(balance).toString()).to.equal("11000000000000000");
      expect(BigNumber.from(raisedAmount).toString()).to.equal(
        "11000000000000000"
      );
      expect(BigNumber.from(contributorAmount).toString()).to.equal(
        "10000000000000000"
      );
      expect(BigNumber.from(thirdAmount).toString()).to.equal(
        "1000000000000000"
      );
    });
    it("Should refund to user", async function () {
      const [owner, other, third] = await ethers.getSigners();
      await (
        await projectFactory.createProject("10000000000000000", "10000000")
      ).wait();
      const testList = await projectFactory.allProject();
      const testContract = await project.attach(
        testList[0] // The deployed contract address
      );
      await expect(testContract.connect(third).refund()).to.be.revertedWith(
        "You are not eligible for refund"
      );
      await (
        await projectFactory.createProject("10000000000000000", "10000")
      ).wait();
      const projectList = await projectFactory.allProject();
      const projectContract = await project.attach(
        projectList[6] // The deployed contract address
      );
      await projectContract.connect(other).sendFunds({
        value: "15000000000000",
      });
      // await expect(testContract.connect(third).refund()).to.be.revertedWith("");
      advanceTimeAndBlock(10000);
      await projectContract.connect(other).refund();
      const contributorAmount = await projectContract.fundContributors(
        other.address
      );
      expect(BigNumber.from(contributorAmount).toString()).to.equal("0");
    });
    it("Should make payment according to request", async function () {
      const [owner, other, third] = await ethers.getSigners();
      await (
        await projectFactory.createProject("10000000000000000", "1000")
      ).wait();
      const projectList = await projectFactory.allProject();
      const projectContract = await project.attach(
        projectList[7] // The deployed contract address
      );
      await projectContract.connect(other).sendFunds({
        value: "15000000000000000",
      });
      // await expect(testContract.connect(third).refund()).to.be.revertedWith("");
      advanceTimeAndBlock(10000);
      await expect(
        projectContract
          .connect(other)
          .createRequest("new", other.address, "10000")
      ).to.be.revertedWith("Only manager can call this function");
      await projectContract
        .connect(owner)
        .createRequest("new", other.address, "10000000000000000");
      await projectContract.connect(owner).makePayment(0);
      const numReq = await projectContract.numRequests();
      const balance = await projectContract.getBalance();
      expect(BigNumber.from(numReq).toString()).to.equal("1");
      expect(BigNumber.from(balance).toString()).to.equal("5000000000000000");
    });
  });
});

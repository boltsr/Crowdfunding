const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const hre = require("hardhat");

describe("ProjectFactory", function () {
  before(async () => {
    const acounts = await ethers.getSigners();
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
    it("Should create the project", async function () {
      await (await projectFactory.createProject("1000", "1000")).wait();
      const projectList = await projectFactory.allProject();
      expect(projectList.length).to.equal(1);
    });
  });
});

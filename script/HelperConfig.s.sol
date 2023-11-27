// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockAggregatorV3Interface.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } 
        else if (block.chainid == 68840142) {
            activeNetworkConfig = getFrameTestnetConfig();
        }
        else {
            activeNetworkConfig = getAnvilNetworkConfig();
        }
    }

    function getSepoliaNetworkConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getFrameTestnetConfig() public returns (NetworkConfig memory) {
        // Deploy priceFeed contract on testnet (no chainlink yet)
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory frameConfig = NetworkConfig({ 
            priceFeed: address(mockPriceFeed) 
            });
        return frameConfig;
    }

    function getAnvilNetworkConfig() public returns (NetworkConfig memory) {
        // To get a price feed address on Anvil we need to:
        // 1. Create and Deploy Mock Contracts
        // 2. Get Back or return the address

        // How I would Do it:
        // 1. Create mock folder and mockAggregatorV3Interface
        // 2. Deploy on Anvil
        // 3. import mock contract to this one

        
        // How patrick Did it

        // 3. Create if statement to check if there is already a {MockV3} in use
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. inherit {Script} and then deploy a new mockAggregatorV3 contract
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        // 2. Pass the mock price feed from the contract above into anvilConfig
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}

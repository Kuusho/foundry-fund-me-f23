-include .env

deploy-frame:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(FRAME_RPC_URL) --private-key $(FRAME_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEP_RPC_URL) --private-key $(SEP_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

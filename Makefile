deploy:
	@echo "You're deploying the contract. Press Enter to proceed."
	@read
	source .env; \
	forge script script/Avatar.s.sol:AvatarDeploy --rpc-url $GOERLI_RPC_URL  --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY -vvvv

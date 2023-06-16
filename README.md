
# DODO V3 contest details

- Join [Sherlock Discord](https://discord.gg/MABEWyASkp)
- Submit findings using the issue page in your private contest repo (label issues as med or high)
- [Read for more details](https://docs.sherlock.xyz/audits/watsons)

# Q&A

### Q: On what chains are the smart contracts going to be deployed?
mainnet, arbitrum, optimism, bnb chain, polygon
___

### Q: Which ERC20 tokens do you expect will interact with the smart contracts? 
any
___

### Q: Which ERC721 tokens do you expect will interact with the smart contracts? 
none
___

### Q: Which ERC777 tokens do you expect will interact with the smart contracts? 
none
___

### Q: Are there any FEE-ON-TRANSFER tokens interacting with the smart contracts?

none
___

### Q: Are there any REBASING tokens interacting with the smart contracts?

none
___

### Q: Are the admins of the protocols your contracts integrate with (if any) TRUSTED or RESTRICTED?
RESTRICTED
___

### Q: Is the admin/owner of the protocol/contracts TRUSTED or RESTRICTED?
TRUSTED
___

### Q: Are there any additional protocol roles? If yes, please explain in detail:
No
___

### Q: Is the code/contract expected to comply with any EIPs? Are there specific assumptions around adhering to those EIPs that Watsons should be aware of?
No
___

### Q: Please list any known issues/acceptable risks that should not result in a valid finding.
none
___

### Q: Please provide links to previous audits (if any).
none
___

### Q: Are there any off-chain mechanisms or off-chain procedures for the protocol (keeper bots, input validation expectations, etc)?
No
___

### Q: In case of external protocol integrations, are the risks of external contracts pausing or executing an emergency withdrawal acceptable? If not, Watsons will submit issues related to these situations that can harm your protocol's functionality.
No
___



# Audit scope


[new-dodo-v3 @ 75ba944a1c5126d73896b853b5baec29b3438311](https://github.com/DODOEX/new-dodo-v3/tree/75ba944a1c5126d73896b853b5baec29b3438311)
- [new-dodo-v3/contracts/DODOV3MM/D3Pool/D3Funding.sol](new-dodo-v3/contracts/DODOV3MM/D3Pool/D3Funding.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Pool/D3MM.sol](new-dodo-v3/contracts/DODOV3MM/D3Pool/D3MM.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Pool/D3Maker.sol](new-dodo-v3/contracts/DODOV3MM/D3Pool/D3Maker.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Pool/D3Storage.sol](new-dodo-v3/contracts/DODOV3MM/D3Pool/D3Storage.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Pool/D3Trading.sol](new-dodo-v3/contracts/DODOV3MM/D3Pool/D3Trading.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Vault/D3Vault.sol](new-dodo-v3/contracts/DODOV3MM/D3Vault/D3Vault.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Vault/D3VaultFunding.sol](new-dodo-v3/contracts/DODOV3MM/D3Vault/D3VaultFunding.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Vault/D3VaultLiquidation.sol](new-dodo-v3/contracts/DODOV3MM/D3Vault/D3VaultLiquidation.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Vault/D3VaultStorage.sol](new-dodo-v3/contracts/DODOV3MM/D3Vault/D3VaultStorage.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Vault/Errors.sol](new-dodo-v3/contracts/DODOV3MM/D3Vault/Errors.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Vault/periphery/D3PoolQuota.sol](new-dodo-v3/contracts/DODOV3MM/D3Vault/periphery/D3PoolQuota.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Vault/periphery/D3RateManager.sol](new-dodo-v3/contracts/DODOV3MM/D3Vault/periphery/D3RateManager.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Vault/periphery/D3Token.sol](new-dodo-v3/contracts/DODOV3MM/D3Vault/periphery/D3Token.sol)
- [new-dodo-v3/contracts/DODOV3MM/D3Vault/periphery/D3UserQuota.sol](new-dodo-v3/contracts/DODOV3MM/D3Vault/periphery/D3UserQuota.sol)
- [new-dodo-v3/contracts/DODOV3MM/lib/CloneFactory.sol](new-dodo-v3/contracts/DODOV3MM/lib/CloneFactory.sol)
- [new-dodo-v3/contracts/DODOV3MM/lib/DODOMath.sol](new-dodo-v3/contracts/DODOV3MM/lib/DODOMath.sol)
- [new-dodo-v3/contracts/DODOV3MM/lib/DecimalMath.sol](new-dodo-v3/contracts/DODOV3MM/lib/DecimalMath.sol)
- [new-dodo-v3/contracts/DODOV3MM/lib/Errors.sol](new-dodo-v3/contracts/DODOV3MM/lib/Errors.sol)
- [new-dodo-v3/contracts/DODOV3MM/lib/InitializableOwnable.sol](new-dodo-v3/contracts/DODOV3MM/lib/InitializableOwnable.sol)
- [new-dodo-v3/contracts/DODOV3MM/lib/MakerTypes.sol](new-dodo-v3/contracts/DODOV3MM/lib/MakerTypes.sol)
- [new-dodo-v3/contracts/DODOV3MM/lib/PMMPricing.sol](new-dodo-v3/contracts/DODOV3MM/lib/PMMPricing.sol)
- [new-dodo-v3/contracts/DODOV3MM/lib/PMMRangeOrder.sol](new-dodo-v3/contracts/DODOV3MM/lib/PMMRangeOrder.sol)
- [new-dodo-v3/contracts/DODOV3MM/lib/Types.sol](new-dodo-v3/contracts/DODOV3MM/lib/Types.sol)
- [new-dodo-v3/contracts/DODOV3MM/periphery/D3MMFactory.sol](new-dodo-v3/contracts/DODOV3MM/periphery/D3MMFactory.sol)
- [new-dodo-v3/contracts/DODOV3MM/periphery/D3MMLiquidationRouter.sol](new-dodo-v3/contracts/DODOV3MM/periphery/D3MMLiquidationRouter.sol)
- [new-dodo-v3/contracts/DODOV3MM/periphery/D3Oracle.sol](new-dodo-v3/contracts/DODOV3MM/periphery/D3Oracle.sol)
- [new-dodo-v3/contracts/DODOV3MM/periphery/D3Proxy.sol](new-dodo-v3/contracts/DODOV3MM/periphery/D3Proxy.sol)



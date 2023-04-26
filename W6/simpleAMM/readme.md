# How to start
cd W6/bigint  
`forge script script/testAMM.s.sol:TestSimpleAMM -vvvvv`
## start a vm node
`anvil --fork-url $env:fork_url`  


## How to setup the evnironments (not this project)
`forge init ${name}`
```
git init
git add . 
git commit -m "Init: Init Project"
git remote add origin https://github.com/penguin72487/KryptoCampSolidity.git
git push origin main

```
```env
RPC_URL = "http://127.0.0.1:8545"
PRIVATE_KEY = ""
ethscan_API = "" 
fork_url = "https://mainnet.infura.io/v3/"
```

## deploy (not this project)
`forge create NFT --rpc-url=$env:RPC_URL --private-key=$env:PRIVATE_KEY --verify --etherscan-api-key=$ethscan_API --constructor-args-path=./constructor_args.json`  
constructor的參數放constructor_args

`cast send --rpc-url=$env:RPC_URL 0x25a1df485cfbb93117f12fc673d87d1cddeb845a "mintTo(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --private-key=$env:PRIVATE_KEY`

## debug
`forge debug --debug script/Counter.s.sol:CounterScript`

## test simpleamm
```powershell
# Load environment variables from .env file
cd W6/simpleAMM
$env_vars = Get-Content -Path .\.env
foreach ($env_var in $env_vars) {
    $key, $value = $env_var.Split("=")
    [System.Environment]::SetEnvironmentVariable($key, $value)
}

# Run the forge test command with the fork_url environment variable
forge test -vvvvv --fork-url $env:fork_url --match-path test/testAMM.t.sol --match-contract TestSimpleAMM
```

forge test -vvvvv --gas-report --fork-url $env:fork_url --match-path test/testAllAMMfunction.t.sol --match-contract TestSimpleAMM




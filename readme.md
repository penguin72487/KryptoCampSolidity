# How to start
cd W6/bigint  
`forge script script/Counter.s.sol:CounterScript -vvvvv`
`forge debug --debug script/Counter.s.sol:CounterScript`
## start a vm node
`anvil --fork-url $env:fork_url`  
`curl --url $env:fork_url -X POST -H   "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'`

## How to setup the evnironments
`forge init ${name}`
```
git init
git add . 
git commit -m "Init: Init Project"
git remote add origin https://github.com/penguin72487/KryptoCampSolidity.git
git push origin master

```
```env
RPC_URL = "http://127.0.0.1:8545"
PRIVATE_KEY = ""
ethscan_API = "" 
fork_url = "https://mainnet.infura.io/v3/"
```

## deploy 
`forge create NFT --rpc-url=$env:RPC_URL --private-key=$env:PRIVATE_KEY --verify --etherscan-api-key=$ethscan_API --constructor-args-path=./constructor_args.json`  
constructor的參數放constructor_args

`cast send --rpc-url=$env:RPC_URL 0x25a1df485cfbb93117f12fc673d87d1cddeb845a "mintTo(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --private-key=$env:PRIVATE_KEY`

## debug

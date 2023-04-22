const rlp = require('rlp')
const keccak = require('keccak')

var nonce = 0xe
var sender = '0xCbB4a73328ce05745c248447AD7199F6D4925D87'

var input_arr = [sender, nonce]
var rlp_encoded = rlp.encode(input_arr)

var contract_address_long = keccak('keccak256')
  .update(Buffer.from(rlp_encoded))
  .digest('hex')

var contract_address = contract_address_long.substring(24)
console.log('contract_address: 0x' + contract_address)
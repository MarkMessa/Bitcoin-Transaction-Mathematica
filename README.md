# Bitcoin Transactions with Mathematica
Package for Mathematica 9.0 with utilities to build raw transactions for Bitcoin.

## Overview
The package contains 4 main functions:
- `buildTransactionInput[txphash, txpiout, scriptSig]` returns an input field for a raw transaction based on the hash of the previous transaction, the output index to redeem from previous transaction and the signature script.
- `buildTransactionOutput[value, pkhash]` returns an output field for a raw transaction based on the redeem value and the public key hash.
- `buildTransaction[txin, txout, "Unsigned"->True]` returns the raw transaction for a given list of inputs and outputs. The "Unsigned" option indicates if it is to return an unsigned or signed raw transaction.
- `scriptSignature[signDER, uncompressPubKey]` returns the signature script *scriptSig* for a given DER encoding signature and an uncompressed public key.


# Bitcoin Transactions with Mathematica
Package for Mathematica 9.0 with utilities to build raw transactions for Bitcoin.

## Overview
The package contains 4 main functions:
- `buildTransactionInput[txphash, txpiout, scriptSig]` returns an input field for a raw transaction based on the hash of the previous transaction, the output index to redeem from previous transaction and the signature script.
- `buildTransactionOutput[value, pkhash]` returns an output field for a raw transaction based on the redeem value and the public key hash.
- `buildTransaction[txin, txout, "Unsigned"->True]` returns the raw transaction for a given list of inputs and outputs. The "Unsigned" option indicates if it is to return an unsigned or signed raw transaction.
- `scriptSignature[signDER, uncompressPubKey]` returns the signature script *scriptSig* for a given DER encoding signature and an uncompressed public key.

## Usage Example
### Unsigned Transaction Stage
```Mathematica
(* load package *)
In[1]:= Get[FileNameJoin[{NotebookDirectory[],"TransacionBuilder.m"}]]
```

Setting variables necessary for input field:
```Mathematica
(* 32-byte reversed hash of the transaction from which to redeem an output *)
In[2]:= txphash={"ec", "cf", "7e", "30", "34", "18", "9b", "85", "19", "85", "d8", "71", "f9", "13", "84", "b8", "ee", "35", "7c", "d4", "7c", "30", "24", "73", "6e", "56", "76", "eb", "2d", "eb", "b3", "f2"};

(* 4-byte little-endian denoting the output index to redeem *)
In[3]:= txpiout={"01","00","00","00"};

(* scriptPubKey of the output to redeem *)
In[4]:= scriptPubKeyOut={"76", "a9", "14", "01", "09", "66", "77", "60", "06", "95", "3d", "55", "67", "43", "9e", "5e", "39", "f8", "6a", "0d", "27", "3b", "ee", "88", "ac"};
```

Building input field of the unsigned raw transaction:
```Mathematica
(** input field of the raw unsigned transaction **)
In[5]:= txuin=buildTransactionInput[txphash, txpiout, scriptPubKeyOut];
Out[5]:= {"ec", "cf", "7e", "30", "34", "18", "9b", "85", "19", "85", "d8", "71", "f9", "13", "84", "b8", "ee", "35", "7c", "d4", "7c", "30", "24", "73", "6e", "56", "76", "eb", "2d", "eb", "b3", "f2", "01", "00", "00", "00", "19", "76", "a9", "14", "01", "09", "66", "77", "60", "06", "95", "3d", "55", "67", "43", "9e", "5e", "39", "f8", "6a", "0d", "27", "3b", "ee", "88", "ac", "ff", "ff", "ff", "ff"}
```

Setting variables necessary for output field:
```Mathematica
(* 8-byte little-endian field (64 bit integer) amount to redeem from the specified output *)
In[6]:= value={"60","5a","f4","05","00","00","00","00"};

(* output script *)
In[7]:= pkhash={"09","70","72","52","44","38","d0","03","d2","3a","2f","23","ed","b6","5a","ae","1b","b3","e4","69"};
```

Building output field of the unsigned raw transaction:
```Mathematica
(** output field of the raw unsigned transaction **)
In[8]:= txuout=buildTransactionOutput[value,pkhash];
Out[8]:= {"60", "5a", "f4", "05", "00", "00", "00", "00", "19", "76", "a9", "14", "09", "70", "72", "52", "44", "38", "d0", "03", "d2", "3a", "2f", "23", "ed", "b6", "5a", "ae", "1b", "b3", "e4", "69", "88", "ac"}
```

Building the complete unsigned transaction based on list of input and output.
```Mathematica
(*** raw unsigned transaction ***)
In[9]:= txu=buildTransaction[txuin,txuout,"Unsigned"->True]
Out[9]:= {"01", "00", "00", "00", "01", "ec", "cf", "7e", "30", "34", "18", "9b", "85", "19", "85", "d8", "71", "f9", "13", "84", "b8", "ee", "35", "7c", "d4", "7c", "30", "24", "73", "6e", "56", "76", "eb", "2d", "eb", "b3", "f2", "01", "00", "00", "00", "19", "76", "a9", "14", "01", "09", "66", "77", "60", "06", "95", "3d", "55", "67", "43", "9e", "5e", "39", "f8", "6a", "0d", "27", "3b", "ee", "88", "ac", "ff", "ff", "ff", "ff", "01", "60", "5a", "f4", "05", "00", "00", "00", "00", "19", "76", "a9", "14", "09", "70", "72", "52", "44", "38", "d0", "03", "d2", "3a", "2f", "23", "ed", "b6", "5a", "ae", "1b", "b3", "e4", "69", "88", "ac", "00", "00", "00", "00", "01", "00", "00", "00"}
```

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
(* loading package *)
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

### Signing Transaction Stage
```Mathematica
(* loading packages *)
In[10]:= Get[FileNameJoin[{NotebookDirectory[], "ECDSA.m"}]];
In[11]:= Get[FileNameJoin[{NotebookDirectory[], "DEREncoding.m"}]];
```


```Mathematica
(* setting private key *)
In[12]:= d = FromDigits["18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725", 16];

(* obtaining public key from private key *)
In[13]:= {xh, yh} = publicKeyECDSA[d];

(* obtaining double-hash of the unsigned transaction*)
In[14]:= z = FromDigits[StringJoin[sha256[sha256[txu]]], 16];

(* obtaining signature of the unsigned transaction *)
In[15]:= {r, s} = signECDSA[z, d];
```


```Mathematica
(* variable-byte ECDSA signature with DER encoding *)
In[16]:= signatureDER = DEREncoding[IntegerString[#, 16, 2] & /@ IntegerDigits[{r, s}, 256, 32]];

(* 65-bytes Uncompress Public Key: x (32-bytes) and y (32-bytes) coordinates followed by 1-byte type 0x04 *)
In[17]:= uncompressPubKey = Join[{"04"}, Flatten[IntegerString[#, 16, 2]&/@IntegerDigits[{xh, yh}, 256, 32]]];

(* creating the signature script *)
In[18]:= scriptSig = scriptSignature[signatureDER, uncompressPubKey]
Out[18]= {"49", "30", "46", "02", "21", "00", "df", "ec", "49", "55", "ef", "e0", "3e", "a5", "75", "93", "8e", "09", "25", "d8", "23", 
"60", "82", "6e", "90", "df", "6b", "3a", "e9", "4b", "90", "51", "ef", "65", "bd", "2c", "b4", "22", "02", "21", "00", "ab", "e2", 
"56", "2c", "92", "4b", "e3", "a4", "fe", "5d", "65", "e5", "1b", "39", "84", "9a", "a9", "40", "60", "da", "25", "d4", "31", "0e", 
"e8", "4b", "f1", "b6", "4e", "37", "51", "dd", "01", "41", "04", "50", "86", "3a", "d6", "4a", "87", "ae", "8a", "2f", "e8", "3c", 
"1a", "f1", "a8", "40", "3c", "b5", "3f", "53", "e4", "86", "d8", "51", "1d", "ad", "8a", "04", "88", "7e", "5b", "23", "52", "2c", 
"d4", "70", "24", "34", "53", "a2", "99", "fa", "9e", "77", "23", "77", "16", "10", "3a", "bc", "11", "a1", "df", "38", "85", "5e", 
"d6", "f2", "ee", "18", "7e", "9c", "58", "2b", "a6"}
```


```Mathematica
(* input field of the raw signed transaction *)
In[19]:= txsin = buildTransactionInput[txphash, txpiout, scriptSig]
Out[19]= {"ec", "cf", "7e", "30", "34", "18", "9b", "85", "19", "85", "d8", "71", "f9", "13", "84", "b8", "ee", "35", "7c", "d4", "7c", 
"30", "24", "73", "6e", "56", "76", "eb", "2d", "eb", "b3", "f2", "01", "00", "00", "00", "8c", "49", "30", "46", "02", "21", "00", 
"df", "ec", "49", "55", "ef", "e0", "3e", "a5", "75", "93", "8e", "09", "25", "d8", "23", "60", "82", "6e", "90", "df", "6b", "3a", 
"e9", "4b", "90", "51", "ef", "65", "bd", "2c", "b4", "22", "02", "21", "00", "ab", "e2", "56", "2c", "92", "4b", "e3", "a4", "fe", 
"5d", "65", "e5", "1b", "39", "84", "9a", "a9", "40", "60", "da", "25", "d4", "31", "0e", "e8", "4b", "f1", "b6", "4e", "37", "51", 
"dd", "01", "41", "04", "50", "86", "3a", "d6", "4a", "87", "ae", "8a", "2f", "e8", "3c", "1a", "f1", "a8", "40", "3c", "b5", "3f", 
"53", "e4", "86", "d8", "51", "1d", "ad", "8a", "04", "88", "7e", "5b", "23", "52", "2c", "d4", "70", "24", "34", "53", "a2", "99", 
"fa", "9e", "77", "23", "77", "16", "10", "3a", "bc", "11", "a1", "df", "38", "85", "5e", "d6", "f2", "ee", "18", "7e", "9c", "58", 
"2b", "a6", "ff", "ff", "ff", "ff"}
```


```Mathematica
(* final raw signed transaction *)
In[20]:= txs = buildTransaction[txsin, txuout, "Unsigned" -> False]
Out[20]= {"01", "00", "00", "00", "01", "ec", "cf", "7e", "30", "34", "18", "9b", "85", "19", "85", "d8", "71", "f9", "13", "84", "b8", 
"ee", "35", "7c", "d4", "7c", "30", "24", "73", "6e", "56", "76", "eb", "2d", "eb", "b3", "f2", "01", "00", "00", "00", "8c", "49", 
"30", "46", "02", "21", "00", "df", "ec", "49", "55", "ef", "e0", "3e", "a5", "75", "93", "8e", "09", "25", "d8", "23", "60", "82", 
"6e", "90", "df", "6b", "3a", "e9", "4b", "90", "51", "ef", "65", "bd", "2c", "b4", "22", "02", "21", "00", "ab", "e2", "56", "2c", 
"92", "4b", "e3", "a4", "fe", "5d", "65", "e5", "1b", "39", "84", "9a", "a9", "40", "60", "da", "25", "d4", "31", "0e", "e8", "4b", 
"f1", "b6", "4e", "37", "51", "dd", "01", "41", "04", "50", "86", "3a", "d6", "4a", "87", "ae", "8a", "2f", "e8", "3c", "1a", "f1", 
"a8", "40", "3c", "b5", "3f", "53", "e4", "86", "d8", "51", "1d", "ad", "8a", "04", "88", "7e", "5b", "23", "52", "2c", "d4", "70", 
"24", "34", "53", "a2", "99", "fa", "9e", "77", "23", "77", "16", "10", "3a", "bc", "11", "a1", "df", "38", "85", "5e", "d6", "f2", 
"ee", "18", "7e", "9c", "58", "2b", "a6", "ff", "ff", "ff", "ff", "01", "60", "5a", "f4", "05", "00", "00", "00", "00", "19", "76", 
"a9", "14", "09", "70", "72", "52", "44", "38", "d0", "03", "d2", "3a", "2f", "23", "ed", "b6", "5a", "ae", "1b", "b3", "e4", "69", 
"88", "ac", "00", "00", "00", "00"}
```

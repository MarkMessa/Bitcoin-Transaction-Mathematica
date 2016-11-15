(*
Bitcoin Transaction Builder for Mathematica
Package to create bitcoin raw transactions with Mathematica 9.0
*)

BeginPackage["BTCTransactionBuilder`"];

	buildTransactionInput::usage="buildTransactionInput[txphash, txpiout, scriptSig] returns the input field for a raw transaction with given previous transaction hash, previous transaction output index to redeem and signature scripts.";
	buildTransactionOutput::usage="buildTransactionOutput[value, pkhash] returns the output field for a raw transaction with given redeem value and public key hash.";
	buildTransaction::usage="buildTransaction[txin, txout, \"Unsigned\"->True] returns the raw transaction for given input and output fields. The \"Unsigned\" option indicates if it is to return an unsigned or signed raw transaction.";

	sha256::usage="sha256[list] returns the SHA256 hash of a hexadecimal list.";
	scriptSignature::usage="scriptSignature[signDER, uncompressPubKey] returns the scriptSig for a given DER encoding signature and an uncompressed public key.";

	Begin["`Private`"];

		buildTransactionInput[txphash_,txpiout_,scriptSig_]:=Module[
			{sequence={"ff","ff","ff","ff"} (* 4-byte sequence (always 0xffffffff) *)},
			Join[txphash,txpiout,{IntegerString[Length[scriptSig],16]},scriptSig,sequence]
		];

		buildTransactionOutput[value_,pkhash_]:=Module[
			{
			opcode1={"76","a9","14"},
			opcode2={"88","ac"},
			scriptPubKey
			}
			,
			scriptPubKey=Join[opcode1,pkhash,opcode2];

			Join[value,{IntegerString[Length[scriptPubKey],16]},scriptPubKey]
		];

		Options[buildTransaction]={"Unsigned"->True};
		buildTransaction[txin_,txout_,OptionsPattern[]]:=Module[
			{
			(* 4-byte little-endian version field *)
			version={"01","00","00","00"},

			(* 1-byte specifying the number of inputs *)
			nin=If[VectorQ[txin],{"01"},{IntegerString[Length[txin],16,2]}],

			(* 1-byte containing the number of outputs in new transaction *)
			nout=If[VectorQ[txout],{"01"},{IntegerString[Length[txout],16,2]}],

			(* 4-byte "lock time" field *)
			lockTime={"00","00","00","00"},

			(* 4-byte "hash code type" (1 in our case) *)
			hashCodeType={"01","00","00","00"}
			}
			,
			Flatten[Join[version,nin,txin,nout,txout,lockTime,If[OptionValue["Unsigned"],hashCodeType,{}]]]
		];
		
		
		sha256[list_]:=IntegerString[#,16,2]&/@IntegerDigits[Hash[FromCharacterCode[FromDigits[#,16]&/@list],"SHA256"],256,32];

		scriptSignature[signDER_,uncompressPubKey_]:=Module[
			{
			type={"01"}, (* 1-byte hash code type *)
			signLength,
			pkLength
			}
			,
			signLength={IntegerString[Length[Join[signDER,type]],16,2]};
			pkLength={IntegerString[Length[uncompressPubKey],16,2]};

			Join[signLength,signDER,type,pkLength,uncompressPubKey]
		];
	End[];
EndPackage[];

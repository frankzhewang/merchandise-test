#!/nas02/apps/mathematica-9.0/bin/MathematicaScript -script

(* Read inputs *)
(* arg[[1]] = id *)
(* arg[[2]] = alpha *)
(* arg[[3]] = mean lambda *)
(* arg[[4]] = gm1/gm3 *)

args = Rest[$ScriptCommandLine];

id = args[[1]];
alpha = ToExpression[args[[2]]];
beta = alpha/ToExpression[args[[3]]];
gm1 = ToExpression[args[[4]]];
lstGm = #/Total[{2*gm1,gm1+1,2}]& /@ {2*gm1,gm1+1,2};

dir = "../out/sol-tab/"<>id;
If[!DirectoryQ[dir],CreateDirectory[dir]];

(* Parameter settings *)

qMax = 30; (* total test inventory *)
p = 20; (* unit selling price *)
lstC = Table[c, {c, 10, 1, -1}]; (* unit procurement costs *)
lstNVRatio = (p-#)/p& /@ lstC; (* ASCENDING newsvendor ratios *)
nNVRatio = Length[lstNVRatio];
t = 1; (* length of the testing period *)
nStore = Length[lstGm];

(* Enumerate all possible sales observations under qMax *)
nSalesIndex = (qMax^3)/6 + qMax^2 + qMax*11/6 + 1; (* 3 stores *)
lstSalesIndex = Array[0 &, nSalesIndex];
mxSalesObs = Array[0 &, {nSalesIndex, nStore}];
cntSalesObs = 0;
Do[
	Do[
		Do[
			cntSalesObs += 1;
    		lstSalesIndex[[cntSalesObs]] = FromDigits[{s1, s2, s3}, qMax + 1];
    		mxSalesObs[[cntSalesObs]] = {s1, s2, s3};
    		, {s3, 0, qMax - s1 - s2}]
	, {s2, 0, qMax - s1}]
, {s1, 0, qMax}];

Assert[nSalesIndex == cntSalesObs];

Print["Total number of possible observations is " <> ToString[nSalesIndex]];
nStockoutIndex = 2^nStore;

(* Initialize the solution tables. For each alpha,beta,t,lstGm, there \
should be a 3x10 solution tables.*)

lstTabSolution = 
  Array[0 &, {nNVRatio, nStore, nSalesIndex, nStockoutIndex}];

(* Compute optimal order quantity for period 2 for each \
(sales,stockout) observation pair *)

Do[ lstSales = mxSalesObs[[iSalesObs]];(* For each sales observation *)
    Do[ lstStockout = IntegerDigits[iStockout - 1, 2, 2]; 
    (* For each stockout observation *)
   
   (* If for some store sales==qMax, then it has to stockout *)
   
   If[Or @@ 
     MapThread[#1 == qMax && #2 == 0 &, {lstSales, lstStockout}], 
    Continue[]];
   
   (* Updating the prior *)
   lstSign = Table[
     If[lstStockout[[n]] == 0, {1}, 
      Join[{1}, ConstantArray[-1, lstSales[[n]]]]]
     , {n, 1, nStore}];
   lstD = Table[
     If[lstStockout[[n]] == 0, {lstSales[[n]]}, 
      Join[{0}, Table[i, {i, 0, lstSales[[n]] - 1}]]]
     , {n, 1, nStore}];
   lstGmPowD = Table[
     If[lstStockout[[n]] == 0, {lstGm[[n]]^lstSales[[n]]}, 
      Join[{1}, Table[lstGm[[n]]^i, {i, 0, lstSales[[n]] - 1}]]]
     , {n, 1, nStore}];
   lstDFact = Table[
     If[lstStockout[[n]] == 0, {Gamma[lstSales[[n]] + 1]}, 
      Join[{1}, Table[Gamma[i + 1], {i, 0, lstSales[[n]] - 1}]]]
     , {n, 1, nStore}];
   lstGmEta = Table[
     If[lstStockout[[n]] == 0, {lstGm[[n]]}, 
      Join[{0}, ConstantArray[lstGm[[n]], lstSales[[n]]]]]
     , {n, 1, nStore}];
   lstProdSign = Flatten[Outer @@ Join[{Times}, lstSign]];
   lstSumD = Flatten[Outer @@ Join[{Plus}, lstD]];
   lstProdGmPowD = Flatten[Outer @@ Join[{Times}, lstGmPowD]];
   lstProdDFact = Flatten[Outer @@ Join[{Times}, lstDFact]];
   lstSumGmEta = Flatten[Outer @@ Join[{Plus}, lstGmEta]];
   lstCoeff = 
    MapThread[#1 Gamma[
         alpha + #2]/(beta + t #5)^(alpha + #2) (t^(#2)) (#3/#4) &
     , {lstProdSign, lstSumD, lstProdGmPowD, lstProdDFact, 
      lstSumGmEta}];
   lstNBinPDF[x_, gm_] = 
    MapThread[
     Binomial[x + alpha + #1 - 1, 
        x] ((beta + #2)/(gm + beta + #2))^(alpha + #1) (gm/(gm + 
            beta + #2))^x &
     , {lstSumD, lstSumGmEta}];
   PredPDF[x_, gm_] = 
    Total[MapThread[#1 #2 &, {lstNBinPDF[x, gm], lstCoeff}]]/
     Total[lstCoeff];
   
   (* Compute solution tables *)
   Do[
    y = 0;
    cum = PredPDF[0, lstGm[[n]]];
    Do[
     While[cum < lstNVRatio[[iNVRatio]],
      y += 1;
      cum += PredPDF[y, lstGm[[n]]];
      ];
     lstTabSolution[[iNVRatio, n, iSalesObs, iStockout]] = y;
     , {iNVRatio, nNVRatio}];
    , {n, nStore}];
   
   , {iStockout, nStockoutIndex}];
  Print["Computation completed for sales observation " <> 
    ToString[iSalesObs]];
, {iSalesObs, nSalesIndex}];

(* Export the solution tables to mat files *)
Do[
	Do[
    	fileName = dir <> "/sol-tab-abGm" <> id
      		<> "-c" <> IntegerString[lstC[[iNVRatio]]]
      		<> "-store" <> IntegerString[n]
      		<> ".mat";
    	Export[fileName, {"TabSol" -> lstTabSolution[[iNVRatio, n]]}, 
     		"LabeledData"];
    , {n, nStore}];
, {iNVRatio, nNVRatio}];
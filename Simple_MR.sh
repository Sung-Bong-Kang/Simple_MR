#!/bin/bash
script_DIR="$( cd "$( dirname "$0" )" && pwd -P )"
## defualt values 
Presso="YES"
if ! options=$(getopt -o h,e:,o:,d:,p:,b:,P: -l help,Exposure:,Outcome:,OutDIRPrefix:,Presso:,bfile:,prink -- "$@")
then
	echo "ERROR: check usage"
	cat $script_DIR/Help
	exit 1
fi
eval set -- "$options"
while true; do
	case "$1" in 
		-h|--help)
			cat $script_DIR/Help
		shift ;;
		-o|--Outcome)
			Outcome="$2"
			echo "-o $Outcome"
		shift 2 ;;
		-e|--Exposure)
			Exposure="$2"
			echo "-e $Exposure"
		shift 2 ;;
		-d|--OutDIRPrifix)
			OutDIRPrefix="$2"
			echo "output dir" $OutDIRPrefix
		shift 2 ;; 
		-p|--Presso)
			Presso="$2"
			if [ $Presso != "NO" ]&&[ $Presso != "YES" ]
			then
				Presso="YES"
			fi
			echo $Presso 
		shift 2 ;;
		-b|--bfile) 
			bfile="$2"
			echo "-b $bfile"
		shift 2 ;;
		-P|--plink) 
			plink="$2"
			echo "-P|--plink $plink"
		shift 2 ;;
		
		-|--)
		shift 
		break
					
	esac
done	
#Options :  help,Exposure:,Outcome:,OutDIRPrefix:,Presso ,bfile prink 

### MAKE OUTPUT DIR 
if [ ! -d $OutDIRPrefix ];
then 
	mkdir $OutDIRPrefix
fi 

if [ "$plink" != "" ] && [ $bfile != "" ]; 
then
   ## LD CLUMPING 	
	$plink --bfile $bfile --allow-no-sex --clump $Exposure --out $OutDIRPrefix/Exposure
   ## make Clumped Exposure and Outcome 
   	awk '{print $3}' $OutDIRPrefix/Exposure.clumped | sed '/^$/d' > $OutDIRPrefix/Exposure.Sig.SNP
   	fgrep -f $OutDIRPrefix/Exposure.Sig.SNP -w $Exposure > $OutDIRPrefix/Exposure.sig
   	fgrep -f $OutDIRPrefix/Exposure.Sig.SNP -w $Outcome  > $OutDIRPrefix/Outcome.sig
   	## removeCovariate info 
   	EX_idx=`fgrep ADD $OutDIRPrefix/Exposure.sig`
   	OUT_idx=`fgrep ADD $OutDIRPrefix/Outcome.sig`
   	if [ "$OUT_idx" != "" ]; 
   	then
		egrep 'ADD|SNP' $OutDIRPrefix/Outcome.sig >$OutDIRPrefix/temp 
	   	mv $OutDIRPrefix/temp $OutDIRPrefix/Outcome.sig
	
   	fi
   	if [ "$EX_idx" != "" ];
   	then
		egrep 'ADD|SNP' $OutDIRPrefix/Exposure.sig > $OutDIRPrefix/temp 
		mv $OutDIRPrefix/temp $OutDIRPrefix/Exposure.sig
   	fi
else
	## NO Plink mode 
	EX_idx=`fgrep ADD $Exposure`
	OUT_idx=`fgrep ADD $Outcome`
	if [ "$OUT_idx" != "" ];
	then
		egrep 'ADD|SNP' $Exposure >$OutDIRPrefix/temp	
		mv $OutDIRPrefix/temp $OutDIRPrefix/Outcome.sig
	else
		ln -s $Outcome $OutDIRPrefix/Outcome.sig
	fi
	if [ "$EX_idx" != "" ]; 
	then
		egrep 'ADD|SNP' $Outcome > $OutDIRPrefix/temp
		mv $OutDIRPrefix/temp $OutDIRPrefix/Exposure.sig
	else 
		ln -s $Exposure $OutDIRPrefix/Exposure.sig 
	fi
	
fi


Ex=$OutDIRPrefix/Exposure.sig
Ot=$OutDIRPrefix/Outcome.sig
echo $OutDIRPrefix ,$Presso
Rscript $script_DIR/MR.R $Ex $Ot $Presso $OutDIRPrefix 

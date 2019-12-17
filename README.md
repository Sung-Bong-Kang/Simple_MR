# Simple Mendelian Randomization (Simple_MR)
Easy and simple mendelian randomization tool using GWAS summary statistics.


Simple Mendelian Randomization(Simple_MR)
  
THIS PROGRAM BUILD BY R 3.6 ver


Need R library :

        MendelianRandomization : an R package for performing Mendelian randomization
                                analyses using summarized data. O Yavorska, S Burgess

        MRPRESSO : Detection of widespread horizontal pleiotropy in causal relationships
                  inferred from Mendelian randomization between complex traits and diseases.
                  Marie Verbanck, Chia-Yen Chen, Benjamin Neale, Ron D.
                  Nature Genetics volume 50, pages693–698(2018)


Require OPTIONS

-h | --help * * * print this help message

-e | --Exposure         require   Exposure Summary statistics

-o | --Outcome           require    Outcome Summary statistics

-d | --OutDIRPrefix       require   Simple MR results out DIR Prefix, Make New Directory, Ansolute Pathway
Optional OPTIONS for Exposure LD clumpling

-p | --Presso        optional   YES or NO defualt YES, Deletion Outlier use MRPRESSO

-P | --plink         optional   plink 1.9 program download by https://www.cog-genomics.org/plink2



input summary statistic file format

Any format usefull!

CAUTIONS

but file head include by SNP,BETA,SE

And White Space Splited data


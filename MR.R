library(MRPRESSO)
library("MendelianRandomization")
args = commandArgs(trailingOnly=TRUE)
EX=read.table(file =args[1],header=T ,sep="")
OUT=read.table(file =args[2],header=T ,sep="")
PRESSO = args[3]
out_dir = args[4]

EX <- EX[,c("SNP","BETA","SE")]
colnames(EX) <- c("SNP","Beta_EX","SE_EX")
OUT<- OUT[,c("SNP","BETA","SE")]
colnames(OUT) <- c("SNP","Beta_OT","SE_OT")
MERGE <-merge(EX,OUT,by = 'SNP')

write.table(MERGE,file=paste(out_dir,"MR_result.txt",sep="/"),append=FALSE,row.names = FALSE,quote=FALSE)
if(PRESSO == "YES"){
PRESSO_results <-mr_presso(BetaOutcome = "Beta_OT", BetaExposure = "Beta_EX", SdOutcome = "SE_OT",SdExposure = "SE_EX",data = MERGE,
			   OUTLIERtest = TRUE,DISTORTIONtest = TRUE,  NbDistribution = 1000,SignifThreshold = 0.05)
Outlier <-  PRESSO_results$`MR-PRESSO results`$`Distortion Test`$`Outliers Indices`
print(is.na(Outlier))
if ((length(Outlier) >0)&(is.na(Outlier) == TRUE )){ 
MERGE <- MERGE[-Outlier,]

}
capture.output(PRESSO_results,file=paste(out_dir,"MR_result.txt",sep="/") ,append=TRUE )
}
MRInputObject <- mr_input(bx = MERGE$Beta_EX, bxse = MERGE$SE_EX, 
			  by = MERGE$Beta_OT,byse = MERGE$SE_OT,snps = MERGE$SNP)

IVWObject <- mr_ivw(MRInputObject,
                    model = "default",
                    robust = FALSE,
                    penalized = FALSE,
                    correl = FALSE,
                    weights = "simple",psi = 0,
                    distribution = "normal",
                    alpha = 0.05)

EggerObject <- mr_egger(MRInputObject,robust = FALSE,penalized = FALSE,correl = FALSE, distribution = "normal",alpha = 0.05)
MRAllObject_egger <- mr_allmethods(MRInputObject, method = "egger")
MRAllObject_all <- mr_allmethods(MRInputObject, method = "all")
print(out_dir)
pdf(paste(out_dir,"MR_plots.pdf",sep="/"))

mr_plot(MRInputObject,error = TRUE, orientate = TRUE, line = "ivw" )

mr_plot(MRAllObject_egger)

mr_plot(mr_allmethods(MRInputObject),error = TRUE, orientate = TRUE, line = "ivw")
dev.off()

#c(IVWObject,EggerObject,MRAllObject_egger)
capture.output(IVWObject,file=paste(out_dir,"MR_result.txt",sep="/") ,append=TRUE )
capture.output(EggerObject,file=paste(out_dir,"MR_result.txt",sep="/") ,append=TRUE )
capture.output(MRAllObject_egger,file=paste(out_dir,"MR_result.txt",sep="/") ,append=TRUE)

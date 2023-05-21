library(readr)
library(readxl)
library(plyr)
library(bruceR)
library(lattice)
library(Rmisc)
library(ggsignif)
library(R.matlab)
library(linkET)
library(RColorBrewer)
library(ggtext)
library(magrittr)
library(psych)
library(reshape)
library(msm)
library(polycor)
library(MASS)
library(ltm)
library(cowplot)
library(patchwork)

datapath <- ('C:/Users/ASUS/Desktop/WatchBaBa/WatchBaBaInMatlab/figure/data')
filename1 <- file.path(datapath,'allAvgDist.mat')
filename2 <- file.path(datapath,'allexpAvgDist.mat')
filename3 <- file.path(datapath,'coarse_seg_agree.mat')
filename4 <- file.path(datapath,'fine_seg_agree.mat')

col_names1 <- paste("video0",1:9,sep="")
col_names2 <- paste("video",10:15,sep="")
col_names <- c(col_names1,col_names2)

allAvgDist <- readMat(filename1)%>%
  data.frame()
colnames(allAvgDist)=col_names

allexpAvgDist <- readMat(filename2)%>%
  data.frame()
colnames(allexpAvgDist)=col_names

coarse_seg_agree <- readMat(filename3)%>%
  data.frame()
colnames(coarse_seg_agree)=col_names

fine_seg_agree <- readMat(filename4)%>%
  data.frame()
colnames(fine_seg_agree)=col_names

exp0col_name <- paste(col_names,'exp0',sep="")
exp1col_name <- paste(col_names,'exp1',sep="")
Dist_0 <- allAvgDist
colnames(Dist_0)=exp0col_name
Dist_1 <- allexpAvgDist
colnames(Dist_1)=exp1col_name

AvgDist <- bind_cols(Dist_0,Dist_1)

sink("AvgDist_ANOVA_result.txt")
MANOVA(AvgDist, dvs="video01exp0:video15exp1", dvs.pattern="video(..)exp(.)",within=c("video", "exp")
       ,sph.correction="GG")%>%
  EMMEANS("video", by="exp") %>%
  EMMEANS("exp", by="video")
sink()

sink("coarse_seg_agree_ANOVA_result.txt")
MANOVA(coarse_seg_agree, dvs="video01:video15", dvs.pattern="video(..)",within="video"
       ,sph.correction="GG")%>%
  EMMEANS("video") 
sink()

sink("fine_seg_agree_ANOVA_result.txt")
MANOVA(fine_seg_agree, dvs="video01:video15", dvs.pattern="video(..)",within="video"
       ,sph.correction="GG")%>%
  EMMEANS("video") 
sink()

split0col_name <- paste(col_names,'split0',sep="")
split1col_name <- paste(col_names,'split1',sep="")
agree_0 <- coarse_seg_agree
colnames(agree_0 )=split0col_name
agree_1 <- fine_seg_agree
colnames(agree_1)=split1col_name

split_agree <- bind_cols(agree_0,agree_1)
sink("split_agree_ANOVA_result.txt")
MANOVA(split_agree, dvs="video01split0:video15split1", dvs.pattern="video(..)split(.)",within=c("video", "split")
       ,sph.correction="GG")%>%
  EMMEANS("video", by="split") %>%
  EMMEANS("split", by="video")
sink()

figDist1 <- pivot_longer(allAvgDist,cols=1:15,names_to="video",values_to="AvgDist")%>%
  mutate(.,expactation=0)
figDist2 <- pivot_longer(allexpAvgDist,cols=1:15,names_to="video",values_to="AvgDist")%>%
  mutate(.,expactation=1)
figDist <- bind_rows(figDist1,figDist2)
figDist$expactation <- factor(figDist$expactation,levels = c("0","1"),labels = c("层次齐性","时间距离期望"))
figDist$video <- factor(figDist$video)

SummaryDist <- summarySE(figDist,measurevar = "AvgDist",groupvars = c("video","expactation"))
Distfig=ggplot(SummaryDist,aes(x=video,y=AvgDist,group=expactation,fill=expactation))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=AvgDist-se,ymax=AvgDist+se),width=.1,position=position_dodge(.7))+
  scale_fill_brewer(palette = "Blues")+
  theme_test()+
  ylab("AvgDist")+
  scale_y_continuous(limits=c(0,23),breaks=seq(0,23,5),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")+
  geom_signif(y_position=(12),xmin=c(1),xmax=c(1),annotation=c("*"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(8),xmin=c(2),xmax=c(2),annotation=c("***"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(15),xmin=c(3),xmax=c(3),annotation=c("*"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(2),xmin=c(4),xmax=c(4),annotation=c("*"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(3),xmin=c(5),xmax=c(5),annotation=c("***"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(3),xmin=c(6),xmax=c(6),annotation=c("***"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(1),xmin=c(7),xmax=c(7),annotation=c("***"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(1),xmin=c(8),xmax=c(8),annotation=c("***"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(2),xmin=c(9),xmax=c(9),annotation=c("***"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(14),xmin=c(10),xmax=c(10),annotation=c("**"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(6),xmin=c(11),xmax=c(11),annotation=c("***"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(7),xmin=c(12),xmax=c(12),annotation=c("***"),tip_length=0,size=0,textsize=8,color="black")+
  geom_signif(y_position=(8),xmin=c(15),xmax=c(15),annotation=c("***"),tip_length=0,size=0,textsize=8,color="black")

figCoa <- pivot_longer(coarse_seg_agree,cols=1:15,names_to="video",values_to="coarse_seg_agree")
figCoa$video <- factor(figCoa$video)
SummaryCoa <- summarySE(figCoa,measurevar = "coarse_seg_agree",groupvars = "video")
Coafig=ggplot(SummaryCoa,aes(x=video,y=coarse_seg_agree))+
  geom_bar(stat="identity",width=.7,color='lightskyblue',fill='lightskyblue',position=position_dodge())+
  geom_errorbar(aes(ymin=coarse_seg_agree-se,ymax=coarse_seg_agree+se),width=.1,position=position_dodge(.7))+
  theme_test()+
  ylab("coarse_seg_agree")+
  scale_y_continuous(limits=c(0,1),breaks=seq(0,1,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")


figFin <- pivot_longer(fine_seg_agree,cols=1:15,names_to="video",values_to="fine_seg_agree")
figFin$video <- factor(figFin$video)
SummaryFin <- summarySE(figFin,measurevar = "fine_seg_agree",groupvars = "video")
Finfig=ggplot(SummaryFin,aes(x=video,y=fine_seg_agree))+
  geom_bar(stat="identity",width=.7,color='lightskyblue',fill='lightskyblue',position=position_dodge())+
  geom_errorbar(aes(ymin=fine_seg_agree-se,ymax=fine_seg_agree+se),width=.1,position=position_dodge(.7))+
  theme_test()+
  ylab("fine_seg_agree")+
  scale_y_continuous(limits=c(0,1),breaks=seq(0,1,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")

figCoa <- mutate(figCoa,split_method=0)
colnames(figCoa)[2] <-"seg_agree"
figFin <- mutate(figFin,split_method=1)
colnames(figFin)[2] <-"seg_agree"
Agreefig <- bind_rows(figCoa,figFin)
Agreefig$split_method <- factor(Agreefig$split_method,levels = c("0","1"),labels = c("coarse","fine"))

SummaryAgree <- summarySE(Agreefig,measurevar = "seg_agree",groupvars = c("video","split_method"))
Agreefig=ggplot(SummaryAgree,aes(x=video,y=seg_agree,group=split_method,fill=split_method))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=seg_agree-se,ymax=seg_agree+se),width=.1,position=position_dodge(.7))+
  scale_fill_brewer(palette = "Blues")+
  theme_test()+
  ylab("seg_agree")+
  scale_y_continuous(limits=c(0,1.1),breaks=seq(0,1,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")

ggsave(filename="Distfig.png",plot=Distfig,width=8,height=5,dpi=2000)
ggsave(filename="Coafig.png",plot=Coafig,width=8,height=5,dpi=2000)
ggsave(filename="Finfig.png",plot=Finfig,width=8,height=5,dpi=2000)
ggsave(filename="Agreefig.png",plot=Agreefig,width=8,height=5,dpi=2000)


Coatutudatapath <- ('C:/Users/ASUS/Desktop/WatchBaBa/WatchBaBaInMatlab/figure/data/GroupData')
Coatutu <- list()
for (i in 1:15){
  tutudataname <- file.path(Coatutudatapath,paste('Video_NO_',as.character(i),'_coarse.mat',sep=""))
  tutudata <- readMat(tutudataname)%>%
    data.frame()
  tutudata<-data.frame(t(tutudata))
  col_tutunames <- paste("sub",1:19,sep="")
  colnames(tutudata) <- col_tutunames
  tutudata <- mutate(tutudata,sum=rowSums(tutudata/19))
  sumtoeach <- data.frame()
  for(j in 1:19){
    sumtoeach_j <- Corr(bind_cols(tutudata[][20],tutudata[][j]),plot='false')%>%
      as_md_tbl()%>%
      filter(.rownames=='sum'&.colnames!='sum')
    sumtoeach <- bind_rows(sumtoeach,sumtoeach_j)
  }
  tutuCorr <- Corr(tutudata[][1:19],plot='false')%>%
    as_md_tbl()
  prline <- sumtoeach%>%
    mutate(rd = cut(r, breaks = c(-Inf, 0.2, 0.4, Inf),
                    labels = c("< 0.3", "0.3 - 0.5", ">= 0.5")),
           pd = cut(p, breaks = c(-Inf, 0.01, 0.05, Inf),
                    labels = c("< 0.01", "0.01 - 0.05", ">= 0.05")))
  Coatutu[[i]] <-qcorrplot(correlate(tutudata[][1:19],method='spearman'), type = "upper", diag = FALSE) +
    geom_tile() +
    geom_mark(size=3.5,sig_level = c(0.05, 0.01, 0.001),
              mark = c("*", "**", "***"),sig_thres=0.05,sep="\n")+
    geom_couple(aes(colour = pd, size = rd), 
                data = prline, 
                curvature = nice_curvature(0.15),
                nudge_x = 0.2,
                label.fontface=2,
                label.size=4.5,
                drop=T) +
    scale_fill_gradientn(colours = RColorBrewer::brewer.pal(11, "RdBu")) +
    scale_size_manual(values = c(0.5, 1, 2)) +
    scale_colour_manual(values = color_pal(3)) +
    guides(size = guide_legend(title = "cor",
                               override.aes = list(colour = "grey35"), 
                               order = 2),
           colour = guide_legend(title = "P_value", 
                                 override.aes = list(size = 3), 
                                 order = 1),
           fill = guide_colorbar(title = "Spearman's r", order = 3))+
    theme(axis.text=element_markdown(color="black",size=10),
          legend.background = element_blank(),
          legend.key = element_blank(),
          plot.title = element_text(hjust = 0.5, vjust = 0, size = 20))+
    labs(title = paste('corr for video NO.',as.character(i),seq=""))
}


Fintutudatapath <- ('C:/Users/ASUS/Desktop/WatchBaBa/WatchBaBaInMatlab/figure/data/GroupData')
Fintutu <- list()
for (i in 1:15){
  tutudataname <- file.path(Fintutudatapath,paste('Video_NO_',as.character(i),'_fine.mat',sep=""))
  tutudata <- readMat(tutudataname)%>%
    data.frame()
  tutudata<-data.frame(t(tutudata))
  col_tutunames <- paste("sub",1:19,sep="")
  colnames(tutudata) <- col_tutunames
  tutudata <- mutate(tutudata,sum=rowSums(tutudata/19))
  sumtoeach <- data.frame()
  for(j in 1:19){
    sumtoeach_j <- Corr(bind_cols(tutudata[][20],tutudata[][j]),plot='false')%>%
      as_md_tbl()%>%
      filter(.rownames=='sum'&.colnames!='sum')
    sumtoeach <- bind_rows(sumtoeach,sumtoeach_j)
  }
  tutuCorr <- Corr(tutudata[][1:19],plot='false')%>%
    as_md_tbl()
  prline <- sumtoeach%>%
    mutate(rd = cut(r, breaks = c(-Inf, 0.2, 0.4, Inf),
                    labels = c("< 0.3", "0.3 - 0.5", ">= 0.5")),
           pd = cut(p, breaks = c(-Inf, 0.01, 0.05, Inf),
                    labels = c("< 0.01", "0.01 - 0.05", ">= 0.05")))
  Fintutu[[i]] <-qcorrplot(correlate(tutudata[][1:19],method='spearman'), type = "upper", diag = FALSE) +
    geom_tile() +
    geom_mark(size=3.5,sig_level = c(0.05, 0.01, 0.001),
              mark = c("*", "**", "***"),sig_thres=0.05,sep="\n")+
    geom_couple(aes(colour = pd, size = rd), 
                data = prline, 
                curvature = nice_curvature(0.15),
                nudge_x = 0.2,
                label.fontface=2,
                label.size=4.5,
                drop=T) +
    scale_fill_gradientn(colours = RColorBrewer::brewer.pal(11, "RdBu")) +
    scale_size_manual(values = c(0.5, 1, 2)) +
    scale_colour_manual(values = color_pal(3)) +
    guides(size = guide_legend(title = "cor",
                               override.aes = list(colour = "grey35"), 
                               order = 2),
           colour = guide_legend(title = "P_value", 
                                 override.aes = list(size = 3), 
                                 order = 1),
           fill = guide_colorbar(title = "Spearman's r", order = 3))+
    theme(axis.text=element_markdown(color="black",size=10),
          legend.background = element_blank(),
          legend.key = element_blank(),
          plot.title = element_text(hjust = 0.5, vjust = 0, size = 20))+
    labs(title = paste('corr for video NO.',as.character(i),seq=""))
}

corrFig_Coa1 = (Coatutu[[1]]|Coatutu[[2]]|Coatutu[[3]])/(Coatutu[[4]]|Coatutu[[5]]|Coatutu[[6]])
corrFig_Coa2 = (Coatutu[[7]]|Coatutu[[8]]|Coatutu[[9]])/(Coatutu[[10]]|Coatutu[[11]]|Coatutu[[12]])
corrFig_Coa3 = (Coatutu[[13]]|Coatutu[[14]]|Coatutu[[15]])
corrFig_Fin1 = (Fintutu[[1]]|Fintutu[[2]]|Fintutu[[3]])/(Fintutu[[4]]|Fintutu[[5]]|Fintutu[[6]])
corrFig_Fin2 = (Fintutu[[7]]|Fintutu[[8]]|Fintutu[[9]])/(Fintutu[[10]]|Fintutu[[11]]|Fintutu[[12]])
corrFig_Fin3 = (Fintutu[[13]]|Fintutu[[14]]|Fintutu[[15]])

ggsave(filename="corrFig_Coa1.png",plot=corrFig_Coa1,width=30,height=18,dpi=400)
ggsave(filename="corrFig_Coa2.png",plot=corrFig_Coa2,width=30,height=18,dpi=400)
ggsave(filename="corrFig_Coa3.png",plot=corrFig_Coa3,width=30,height=18,dpi=400)
ggsave(filename="corrFig_Fin1.png",plot=corrFig_Fin1,width=30,height=18,dpi=400)
ggsave(filename="corrFig_Fin2.png",plot=corrFig_Fin2,width=30,height=18,dpi=400)
ggsave(filename="corrFig_Fin3.png",plot=corrFig_Fin3,width=30,height=18,dpi=400)
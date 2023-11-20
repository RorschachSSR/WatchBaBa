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

col_names1 <- paste("lvl",c(1,1,1,2,2,2,3,3,3,4,4,4,5,5,5),sep="")
col_names2 <- paste("noval",c(3,1,2,3,1,2,3,1,2,3,1,2,3,1,2),sep="")
col_names <- paste(col_names1,col_names2,sep="")

allAvgDist <- readMat(filename1)%>%
  data.frame()
colnames(allAvgDist)=col_names
allAvgDist <- allAvgDist[,c(2,3,1,5,6,4,8,9,7,11,12,10,14,15,13)]

allexpAvgDist <- readMat(filename2)%>%
  data.frame()
colnames(allexpAvgDist)=col_names
allexpAvgDist <- allexpAvgDist[,c(2,3,1,5,6,4,8,9,7,11,12,10,14,15,13)]

coarse_seg_agree <- readMat(filename3)%>%
  data.frame()
colnames(coarse_seg_agree)=col_names
coarse_seg_agree <- coarse_seg_agree[,c(2,3,1,5,6,4,8,9,7,11,12,10,14,15,13)]

fine_seg_agree <- readMat(filename4)%>%
  data.frame()
colnames(fine_seg_agree)=col_names
fine_seg_agree <- fine_seg_agree[,c(2,3,1,5,6,4,8,9,7,11,12,10,14,15,13)]

exp0col_name <- paste(colnames(allAvgDist),'exp0',sep="")
exp1col_name <- paste(colnames(allexpAvgDist),'exp1',sep="")
Dist_0 <- allAvgDist
colnames(Dist_0)=exp0col_name
Dist_1 <- allexpAvgDist
colnames(Dist_1)=exp1col_name

AvgDist <- bind_cols(Dist_0,Dist_1)

sink("AvgDist_ANOVA_result.txt")
MANOVA(AvgDist, dvs="lvl1noval1exp0:lvl5noval3exp1", dvs.pattern="lvl(.)noval(.)exp(.)",within=c("lvl","noval", "exp")
       ,sph.correction="GG")%>%
  EMMEANS("lvl", by="exp") %>%
  EMMEANS("exp",by="lvl")
sink()

sink("coarse_seg_agree_ANOVA_result.txt")
MANOVA(coarse_seg_agree, dvs="lvl1noval1:lvl5noval3", dvs.pattern="lvl(.)noval(.)",within=c("lvl","noval")
       ,sph.correction="GG")%>%
  EMMEANS("lvl")%>%
  EMMEANS("noval")
sink()

sink("fine_seg_agree_ANOVA_result.txt")
MANOVA(fine_seg_agree, dvs="lvl1noval1:lvl5noval3", dvs.pattern="lvl(.)noval(.)",within=c("lvl","noval")
       ,sph.correction="GG")%>%
  EMMEANS("lvl")%>%
  EMMEANS("noval") 
sink()

split0col_name <- paste(colnames(coarse_seg_agree),'split0',sep="")
split1col_name <- paste(colnames(fine_seg_agree),'split1',sep="")
agree_0 <- coarse_seg_agree
colnames(agree_0 )=split0col_name
agree_1 <- fine_seg_agree
colnames(agree_1)=split1col_name

split_agree <- bind_cols(agree_0,agree_1)
sink("split_agree_ANOVA_result.txt")
MANOVA(split_agree, dvs="lvl1noval1split0:lvl5noval3split1", dvs.pattern="lvl(.)noval(.)split(.)",within=c("lvl","noval", "split")
       ,sph.correction="GG")%>%
  EMMEANS("lvl", by="split") %>%
  EMMEANS("split",by="lvl")
sink()

figDist1 <- pivot_longer(allAvgDist,cols=1:15,names_to="video",values_to="AvgDist")%>%
  mutate(.,expactation=0)%>%
  separate(.,video,sep="n",into=c("level","noval_level"))

figDist2 <- pivot_longer(allexpAvgDist,cols=1:15,names_to="video",values_to="AvgDist")%>%
  mutate(.,expactation=1)%>%
  separate(.,video,sep="n",into=c("level","noval_level"))

figDist <- bind_rows(figDist1,figDist2)
figDist$expactation <- factor(figDist$expactation,levels = c("0","1"),labels = c("层次齐性","时间距离期望"))
figDist$level <- factor(figDist$level)
figDist$noval_level <- factor(figDist$noval_level,levels = c("oval1","oval2","oval3"),
                              labels = c("noval1","noval2","noval3"))


SummaryDist <- summarySE(figDist,measurevar = "AvgDist",groupvars = c("level","noval_level","expactation"))
Distfig1=ggplot(filter(SummaryDist,expactation=="层次齐性"),aes(x=level,y=AvgDist,group=noval_level,fill=noval_level))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=AvgDist-se,ymax=AvgDist+se),width=.1,position=position_dodge(.7))+
  scale_fill_brewer(palette = "Blues")+
  theme_test()+
  ylab("AvgDist")+
  scale_y_continuous(limits=c(0,21),breaks=seq(0,21,5),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")+
  geom_signif(y_position=(3),xmin=c(2),xmax=c(3),annotation=c("*"),tip_length=.02,size=1,textsize=8,color="black")+
  geom_signif(y_position=(6),xmin=c(3),xmax=c(4),annotation=c("**"),tip_length=.02,size=1,textsize=8,color="black")

Distfig2=ggplot(filter(SummaryDist,expactation=="时间距离期望"),aes(x=level,y=AvgDist,group=noval_level,fill=noval_level))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=AvgDist-se,ymax=AvgDist+se),width=.1,position=position_dodge(.7))+
  scale_fill_brewer(palette = "Blues")+
  theme_test()+
  ylab("expAvgDist")+
  scale_y_continuous(limits=c(0,30),breaks=seq(0,30,5),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")+
  geom_signif(y_position=(18),xmin=c(1),xmax=c(2),annotation=c("*"),tip_length=.02,size=1,textsize=8,color="black")+
  geom_signif(y_position=(22),xmin=c(1),xmax=c(3),annotation=c("*"),tip_length=.02,size=1,textsize=8,color="black")+
  geom_signif(y_position=(6),xmin=c(2),xmax=c(3),annotation=c("***"),tip_length=.02,size=1,textsize=8,color="black")+
  geom_signif(y_position=(14),xmin=c(2),xmax=c(4),annotation=c("*"),tip_length=.02,size=1,textsize=8,color="black")+
  geom_signif(y_position=(19),xmin=c(3),xmax=c(4),annotation=c("*"),tip_length=.02,size=1,textsize=8,color="black")

Distfig <- plot_grid(
  Distfig1, Distfig2, labels = "auto",
  align = "h")

figCoa <- pivot_longer(coarse_seg_agree,cols=1:15,names_to="video",values_to="coarse_seg_agree")%>%
  separate(.,video,sep="n",into=c("level","noval_level"))
figCoa$level <- factor(figCoa$level)
figCoa$noval_level <- factor(figCoa$noval_level,levels = c("oval1","oval2","oval3"),
                              labels = c("noval1","noval2","noval3"))


SummaryCoa <- summarySE(figCoa,measurevar = "coarse_seg_agree",groupvars = c("level","noval_level"))
Coafig=ggplot(SummaryCoa,aes(x=level,y=coarse_seg_agree,group=noval_level,fill=noval_level))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=coarse_seg_agree-se,ymax=coarse_seg_agree+se),width=.1,position=position_dodge(.7))+
  theme_test()+
  scale_fill_brewer(palette = "Blues")+
  ylab("coarse_seg_agree")+
  scale_y_continuous(limits=c(0,1.6),breaks=seq(0,1.0,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")+
  geom_signif(y_position=(1.0),xmin=c(1),xmax=c(2),annotation=c("***"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)+
  geom_signif(y_position=(1.1),xmin=c(1),xmax=c(3),annotation=c("***"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)+
  geom_signif(y_position=(1.2),xmin=c(2),xmax=c(3),annotation=c("***"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)+
  geom_signif(y_position=(1.3),xmin=c(2),xmax=c(4),annotation=c("***"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)+
  geom_signif(y_position=(1.4),xmin=c(2),xmax=c(5),annotation=c("***"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)+
  geom_signif(y_position=(1.5),xmin=c(3),xmax=c(5),annotation=c("***"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)
  


figFin <- pivot_longer(fine_seg_agree,cols=1:15,names_to="video",values_to="fine_seg_agree")%>%
  separate(.,video,sep="n",into=c("level","noval_level"))
figFin$level <- factor(figFin$level)
figFin$noval_level <- factor(figFin$noval_level,levels = c("oval1","oval2","oval3"),
                             labels = c("noval1","noval2","noval3"))
SummaryFin <- summarySE(figFin,measurevar = "fine_seg_agree",groupvars = c("level","noval_level"))
Finfig=ggplot(SummaryFin,aes(x=level,y=fine_seg_agree,group=noval_level,fill=noval_level))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=fine_seg_agree-se,ymax=fine_seg_agree+se),width=.1,position=position_dodge(.7))+
  theme_test()+
  scale_fill_brewer(palette = "Blues")+
  ylab("fine_seg_agree")+
  scale_y_continuous(limits=c(0,1.4),breaks=seq(0,1,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")+
  geom_signif(y_position=(0.9),xmin=c(1),xmax=c(2),annotation=c("*"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)+
  geom_signif(y_position=(1.0),xmin=c(1),xmax=c(3),annotation=c("**"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)+
  geom_signif(y_position=(1.1),xmin=c(2),xmax=c(4),annotation=c("*"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)+
  geom_signif(y_position=(1.2),xmin=c(3),xmax=c(4),annotation=c("**"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)+
  geom_signif(y_position=(1.3),xmin=c(3),xmax=c(5),annotation=c("**"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)

figCoa <- mutate(figCoa,split_method=0)
colnames(figCoa)[3] <-"seg_agree"
figFin <- mutate(figFin,split_method=1)
colnames(figFin)[3] <-"seg_agree"
Agreefig <- bind_rows(figCoa,figFin)
Agreefig$split_method <- factor(Agreefig$split_method,levels = c("0","1"),labels = c("coarse","fine"))

SummaryAgree <- summarySE(Agreefig,measurevar = "seg_agree",groupvars = c("level","noval_level","split_method"))
Agreefig1=ggplot(filter(SummaryAgree,level=="lvl1"),aes(x=split_method,y=seg_agree,group=noval_level,fill=noval_level))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=seg_agree-se,ymax=seg_agree+se),width=.1,position=position_dodge(.7))+
  scale_fill_brewer(palette = "Blues")+
  theme_test()+
  ylab("seg_agree")+
  scale_y_continuous(limits=c(0,1.1),breaks=seq(0,1,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")
Agreefig2=ggplot(filter(SummaryAgree,level=="lvl2"),aes(x=split_method,y=seg_agree,group=noval_level,fill=noval_level))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=seg_agree-se,ymax=seg_agree+se),width=.1,position=position_dodge(.7))+
  scale_fill_brewer(palette = "Blues")+
  theme_test()+
  ylab("seg_agree")+
  scale_y_continuous(limits=c(0,1.1),breaks=seq(0,1,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")+
  geom_signif(y_position=(1.0),xmin=c(1),xmax=c(2),annotation=c("**"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)
Agreefig3=ggplot(filter(SummaryAgree,level=="lvl3"),aes(x=split_method,y=seg_agree,group=noval_level,fill=noval_level))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=seg_agree-se,ymax=seg_agree+se),width=.1,position=position_dodge(.7))+
  scale_fill_brewer(palette = "Blues")+
  theme_test()+
  ylab("seg_agree")+
  scale_y_continuous(limits=c(0,1.1),breaks=seq(0,1,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")+
  geom_signif(y_position=(1.02),xmin=c(1),xmax=c(2),annotation=c("*"),tip_length=.02,size=1,textsize=8,color="black",vjust=.32)
Agreefig4=ggplot(filter(SummaryAgree,level=="lvl4"),aes(x=split_method,y=seg_agree,group=noval_level,fill=noval_level))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=seg_agree-se,ymax=seg_agree+se),width=.1,position=position_dodge(.7))+
  scale_fill_brewer(palette = "Blues")+
  theme_test()+
  ylab("seg_agree")+
  scale_y_continuous(limits=c(0,1.1),breaks=seq(0,1,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")
Agreefig5=ggplot(filter(SummaryAgree,level=="lvl5"),aes(x=split_method,y=seg_agree,group=noval_level,fill=noval_level))+
  geom_bar(stat="identity",width=.7,position=position_dodge())+
  geom_errorbar(aes(ymin=seg_agree-se,ymax=seg_agree+se),width=.1,position=position_dodge(.7))+
  scale_fill_brewer(palette = "Blues")+
  theme_test()+
  ylab("seg_agree")+
  scale_y_continuous(limits=c(0,1.1),breaks=seq(0,1,0.2),expand = c(0,0))+
  theme(axis.title = element_text(family="serif"),axis.text = element_text(family="serif"),axis.ticks.x=element_blank(),legend.title=element_blank(),legend.position="top")
Agreefig <- plot_grid(
  Agreefig1, Agreefig2,Agreefig3,Agreefig4,Agreefig5, labels = "auto",
  align = "h")


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


datapath <- ('C:/Users/ASUS/Desktop/WatchBaBa/WatchBaBaInMatlab/figure/data')
creaname <- file.path(datapath,'creaPoint.mat')
creaPoint <- readMat(creaname)%>%
  data.frame()
colnames(creaPoint)=col_names
creaPoint <- creaPoint[,c(2,3,1,5,6,4,8,9,7,11,12,10,14,15,13)]

for(i in 1:19){
  MAX <- max(creaPoint[i,])
  MIN <- min(creaPoint[i,])
  for (j in 1:15){
    creaPoint[i,j]=(creaPoint[i,j]-MIN)/(MAX-MIN)
  }
}

lmData <-bind_cols(pivot_longer(creaPoint,cols= 1:15,names_to = "video",values_to = "creaPoint"),
                   data.frame(allAvgdist=pivot_longer(allAvgDist,cols= 1:15,names_to = "video",values_to = "allAvgdist")$allAvgdist),
                   data.frame(allexpAvgDist=pivot_longer(allexpAvgDist,cols= 1:15,names_to = "video",values_to = "allexpAvgDist")$allexpAvgDist),
                   data.frame(coarse_seg_agree=pivot_longer(coarse_seg_agree,cols= 1:15,names_to = "video",values_to = "coarse_seg_agree")$coarse_seg_agree),
                   data.frame(fine_seg_agree=pivot_longer(fine_seg_agree,cols= 1:15,names_to = "video",values_to = "fine_seg_agree")$fine_seg_agree))%>%
  separate(.,video,sep="n",into=c("level","noval_level"))
lmData$level <- factor(lmData$level)
lmData$noval_level <- factor(lmData$noval_level,levels = c("oval1","oval2","oval3"),
                             labels = c("noval1","noval2","noval3"))

lmData$hie_align <- lmData$allAvgdist/lmData$allexpAvgDist
L_model <- lm(creaPoint ~ hie_align+coarse_seg_agree+level+noval_level  , data = lmData)
sink("creaRegression.txt")
GLM_summary(L_model)
sink()
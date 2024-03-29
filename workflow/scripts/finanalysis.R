# Importing data frames ####

# Posting this for posterity so I know where this data came from

# dframesex1 <- data.frame(dframe1$id[-12115],dframe1$Country[-12115],dframe1$Genes[-12115],dframe1$AMR.Gene.symbol[-12115],
#                          rep('',35311),rep('',35311))
# rownames(dframesex1) <- dframe1$id[-12115]
# colnames(dframesex1) <- c('id','Country','Genes','AMR.Gene.symbol','Host.sex','Sexual.behaviour')
# for(r in 1:nrow(metadatamaster)) {
#   dframesex1[metadatamaster$displayname[r],'Host.sex'] <- metadatamaster$Host.sex[r]
#   dframesex1[metadatamaster$displayname[r],'Sexual.behaviour'] <- metadatamaster$Sexual.behaviour[r]
#   dframesex1[paste(metadatamaster$displayname[r],'1',sep='_'),'Host.sex'] <- metadatamaster$Host.sex[r]
#   dframesex1[paste(metadatamaster$displayname[r],'1',sep='_'),'Sexual.behaviour'] <- metadatamaster$Sexual.behaviour[r]
#   print(r)
# }
# origname <- ''
# for(n in 1:nrow(dframesex)) {
#   if(is.na(dframesex1$id[n])) {
#     placename <- rownames(dframesex)[n]
#     if(endsWith(rownames(dframesex)[n],'_1')) {
#       origname <- substr(placename,1,nchar(placename) - 2 )
#       print(origname)
#       dframesex$id[n] <- rownames(dframesex)[n]
#       dframesex$Country[n] <- dframesex[origname,'Country']
#       dframesex$Genes[n] <- dframesex[origname,'Genes']
#       dframesex$AMR.Gene.symbol[n] <- dframesex[origname,'AMR.Gene.symbol']
#     }
#   }
# }
# 
# write.csv(dframesex1,file='~/PRACS/results/dframesex1.csv')
#
# I imported the data from python as dframe1 (statsdataclean.csv) and the data
# from compiled metadata as metadatamaster because we needed host sex and behaviour
# information from metadatamaster then compiled them into dframesex1.csv

# import libraries
library(ggplot2)

# import data frame
dframesex1 <- read.csv(file='~/PRACS/results/dframesex1.csv')
dframesex <- data.frame(dframesex1[,-1])
rownames(dframesex) <- dframesex1$X
# now i have a data frame to work with, dframesex that is a) targetable by 
# isolate (dframesex['SAMN1234',]) AND has id in the dframe

# First step, clean Sexual.behaviour data in place. 

dframesex$Sexual.behaviour[dframesex1$Sexual.behaviour == 'Heterosexual men'] <-
  'WSM'
dframesex$Host.sex[dframesex1$Sexual.behaviour == 'Heterosexual men'] <-
  'female'
# all people listed with homosexual are men
dframesex$Sexual.behaviour[dframesex$Sexual.behaviour == 'Homosexual'] <- 'MSM'
dframesex$Sexual.behaviour[dframesex$Sexual.behaviour == 'Bisexual MSM'] <- 'MSMW'
dframesex$Sexual.behaviour[dframesex$Sexual.behaviour == 'WSM-E'] <- 'WSM'
# all people listed with bi-sexual have no sex listed
dframesex$Sexual.behaviour[dframesex$Sexual.behaviour == 'Bi-sexual'] <- ''
dframesex$Sexual.behaviour[dframesex$Sexual.behaviour == 'Unknown'] <- ''
dframesex$Sexual.behaviour[is.na(dframesex$Sexual.behaviour)] <- ''
# all people listed with bisexual are men
dframesex$Sexual.behaviour[dframesex$Sexual.behaviour == 'Bisexual'] <- 'MSMW'
# all people listed with women have no sex listed
dframesex$Sexual.behaviour[dframesex$Sexual.behaviour == 'Women'] <- ''
for(r in 1:nrow(dframesex)) {
  if(dframesex$Sexual.behaviour[r] == 'Heterosexual') {
    if(dframesex$Host.sex[r] == 'male') {
      dframesex$Host.sex[r] <- 'MSW'
    }else if(dframesex$Host.sex[r] == 'female') {
      dframesex$Host.sex[r] <- 'WSM'
    }else {
      dframesex$Sexual.behaviour[r] <- ''
    }
  }
}
# unique(dframesex1$Sexual.behaviour)

# Define functions ####
# categorise_cas takes a string list of cas genes and returns a vector of unique
# cas categories etc 'cas4_abcd,cas8c_blah,cas4_efgh' -> c('cas4','cas8c')
# if given empty string returns NULL (empty list)
categorise_cas <- function(cas_list) {
  return_list <- c()
  if(!(cas_list == '' )) {
    cas_list <- unlist(strsplit(cas_list,','))
    for(n in 1:length(cas_list)) {
      return_list <- unique(c(return_list,strsplit(cas_list[n],'_')[[1]][1]))
    }
  }
  return(return_list)
}
# categorise_amr takes a string list of AMR genes and returns a vector of unique
# mechanism categories
amr_mechanism_class <- function(amr_list) {
  return_list <- c()
  if(!(amr_list == '' )) {
    amr_list <- unlist(strsplit(amr_list,','))
    for(n in 1:length(amr_list)) {
      amr <- amr_list[n]
      if(startsWith(amr,'penA')) {
        return_list <- c(return_list,'penA variant')
      }else if(startsWith(amr,'bla')) {
        return_list <- c(return_list,'bla variant')
      }else if(startsWith(amr,'par')) {
        return_list <- c(return_list,'parC/E variant')
      }else if(startsWith(amr,'por')) {
        return_list <- c(return_list,'Porins')
      }else if(startsWith(amr,'gyr')) {
        return_list <- c(return_list,'gyrA/B variant')
      }else if(startsWith(amr,'mtr')) {
        return_list <- c(return_list,'mtr variant')
      }else if(startsWith(amr,'rpoB')) {
        return_list <- c(return_list,'rpoB variant')
      }else if(startsWith(amr, 'rpsJ')) {
        return_list <- c(return_list,'rpsJ')
      }else if(startsWith(amr,'rpsE')) {
        return_list <- c(return_list,'rpsE')
      }else if(startsWith(amr,'rpoD')) {
        return_list <- c(return_list,'rpoD variant')
      }else if(startsWith(amr,'tet')) {
        return_list <- c(return_list,'tet variant')
      }else if(startsWith(amr,'msr')) {
        return_list <- c(return_list,'msr(E)')
      }else if(startsWith(amr,'aph')) {
        return_list <- c(return_list,'aph variant')
      }else if(startsWith(amr,'erm')) {
        return_list <- c(return_list,'erm variant')
      }else if(startsWith(amr,'rpl')) {
        return_list <- c(return_list,'rplD/V variant')
      }else if(startsWith(amr,'mph')) {
        return_list <- c(return_list,'mph(E)')
      }else if(startsWith(amr,'fosB')) {
        return_list <- c(return_list,'fosB')
      }else if(startsWith(amr,'sul2')) {
        return_list <- c(return_list,'sul2')
      }else if(startsWith(amr,'fosB')) {
        return_list <- c(return_list,'fosB')
      }else if(startsWith(amr,'dfr')) {
        return_list <- c(return_list,'dfrA14')
      }else if(startsWith(amr,'23S')) {
        return_list <- c(return_list,'23S_A2045G')
      }else if(startsWith(amr,'fosB')) {
        return_list <- c(return_list,'fosB')
      }else if(startsWith(amr,'folP')) {
        return_list <- c(return_list,'folP')
      }else if(startsWith(amr,'catA')) {
        return_list <- c(return_list,'catA')
      }else if(startsWith(amr,'qacC')) {
        return_list <- c(return_list,'qacC')
      }else if(startsWith(amr,'norM')) {
        return_list <- c(return_list,'norM')
      }else if((startsWith(amr,'ponA')) | (startsWith(amr,'pbp2'))) {
        return_list <- c(return_list,'PBP variant')
      }
    }
    return(unique(return_list))
  }
}
# get_all_genes takes a list of lists, for example a data.frame column of lists
# and returns a unique list of all the entries found. Works on amr or cas data,
# given type='amr' or type='cas' using functions categorise_cas() and
# amr_mechanism_class
get_all_genes <- function(list_of_lists, type) {
  return_list <- c()
  if(type == 'amr') {
    for(n in 1:length(list_of_lists)) {
      return_list <- unique(c(return_list,amr_mechanism_class(list_of_lists[n])))
    }
  }
  if(type == 'cas') {
    for(n in 1:length(list_of_lists)) {
      return_list <- unique(c(return_list,categorise_cas(list_of_lists[n])))
    }
  }
  return(return_list)
}
# categorise_who_region takes a country name and returns the who region of that country
categorise_who_region <- function(country){
  returncontinent <- switch(country, 'Australia' = 'WPR', 'New Zealand' = 'WPR', 
                            'Netherlands' = 'EUR', 'Estonia' = 'EUR', 'Latvia' = 'EUR', 
                            'Switzerland' = 'EUR', 'Scotland' = 'EUR', 'Norway' = 'EUR',
                            'Hungary' = 'EUR', 'Denmark' = 'EUR', 'Spain' = 'EUR', 
                            'Belgium' = 'EUR', 'Malta' = 'EUR', 'Romania' = 'EUR',
                            'Lithuania' = 'EUR', 'Poland' = 'EUR', 'Portugal' = 'EUR',
                            'Czechia' = 'EUR', 'Cyprus' = 'EUR', 'Finland' = 'EUR',
                            'Croatia' = 'EUR', 'Ukraine' = 'EUR', 'Turkey' = 'EUR',
                            'Saudi Arabia' = 'EMR', 'Austria' = 'EUR', 'Slovakia' = 'EUR',
                            'Germany' = 'EUR', 'Ireland' = 'EUR', 'Belarus' = 'EUR',
                            'Russia' = 'EUR', 'Bulgaria' = 'EUR', 'Sweden' = 'EUR',
                            'Italy' = 'EUR', 'Slovenia' = 'EUR', 'France' = 'EUR',
                            'Greece' = 'EUR', 'Iceland' = 'EUR', 'Brazil' = 'AMC',
                            'Japan' = 'WPR', 'China' = 'WPR', 'Guinea-Bissau' = 'AFR', 
                            'India' = 'SEAR', 'Chile' = 'AMC', 'Tanzania' = 'AFR',
                            'Armenia' = 'EUR', 'Ecuador' = 'AMC', 'Vietnam' = 'WPR',
                            'Philippines' = 'WPR', 'Korea' = 'WPR', 'Pakistan' = 'EMR', 
                            'Gambia' = 'AFR', 'Caribbean' = 'AMC', 'USA' = 'AMC',
                            'UK' = 'EUR', 'Suriname' = 'AMC', 'Angola' = 'AFR',
                            'South Africa' = 'AFR', 'Argentina' = 'AMC', 'Thailand' = 'SEAR',
                            'Singapore' = 'WPR', 'Canada' = 'AMC', 'Brazil' = 'AMC',
                            'Guinea' = 'AFR', 'Kenya' = 'AFR', 'Hong Kong' = 'WPR', 'Bhutan' = 'SEAR',
                            'Ivory Coast' = 'AFR', 'Malaysia' = 'WPR', 'Indonesia' = 'SEAR',
                            'Morocco' = 'EMR', 'Uganda' = 'AFR')
  
  if(is.null(returncontinent) == TRUE) {
    return('')
  }else {
    return(returncontinent)
  }
}
# create lists of all sex networks, all cas genes and all amr genes and all countries
# for efficient data frame construction. remove empty entries
{allcasgenes <- get_all_genes(dframesex$Genes,'cas')
  allmechclasses <- get_all_genes(dframesex$AMR.Gene.symbol,'amr')
  allsexnetworks <- unique(dframesex$Sexual.behaviour)
  allsexnetworks <- allsexnetworks[ !allsexnetworks == '' ]
  allcountries <- unique(dframesex$Country)
  allcountries <- allcountries[ !allcountries == '']
}

# create plot of amr cat by country ####
# create count matrix
{
  dfamrbycountry <- (matrix(0, nrow=(length(allcountries)),ncol=(length(allmechclasses))))
  rownames(dfamrbycountry) <- allcountries
  colnames(dfamrbycountry) <- allmechclasses
  for(r in 1:nrow(dframesex)) {
    country <- dframesex$Country[r]
    amr_list <- amr_mechanism_class(dframesex$AMR.Gene.symbol[r]) 
    for(n in 1:length(amr_list)) {
      if(country %in% allcountries) {
        dfamrbycountry[country,amr_list[n]] <- dfamrbycountry[country,amr_list[n]] + 1
      }
    }
  }
  amrbycountrycountnorm <- c()
  amrbycountryamr <- c()
  amrbycountrycountry <- c()
  amrbycountrycontinent <- c()
  for(r in 1:nrow(dfamrbycountry)) {
    for(c in 1:ncol(dfamrbycountry)) {
      amrbycountrycountnorm <- c(amrbycountrycountnorm, 
                                 (dfamrbycountry[r,c] / sum(dfamrbycountry[r,])))
      amrbycountryamr <- c(amrbycountryamr,colnames(dfamrbycountry)[c])
      amrbycountrycountry <- c(amrbycountrycountry,rownames(dfamrbycountry)[r])
      amrbycountrycontinent <- c(amrbycountrycontinent,categorise_who_region(
        rownames(dfamrbycountry)[r]))
    }
  }
  dfplotamrbycountry <- data.frame(amrbycountrycountnorm,amrbycountryamr,amrbycountrycountry,amrbycountrycontinent)
}
for(n in 1:length(amrbycountrycountry)) {
  print(paste(amrbycountrycountry[n],amrbycountrycontinent[n]))
}
amrbycountrycontinent
# create plot
ggplot(dfplotamrbycountry,aes(fill=amrbycountryamr, y=amrbycountrycountnorm, x=amrbycountrycountry)) + 
  geom_bar(position='stack', stat='identity') +
  ggtitle('Relative frequency of Resistance genes found by Country') +
  xlab('Country') + ylab('Resistance Gene Frequency') +
  labs(color='Gene') + coord_flip() + theme_minimal() + 
  scale_y_continuous(labels = scales::percent) #+ theme(legend.position = "none")

# create plot with continent sorting

ggplot(dfplotamrbycountry,aes(colour = amrbycountryamr, fill = amrbycountryamr, y = amrbycountrycountnorm,
                             x = amrbycountrycountry)) + 
  geom_bar(position="stack", stat="identity",  width=.7) +
  xlab('Country') + ylab('Resistance Gene Frequency') + theme_classic() +
  #theme(legend.position = 'None')  + 
  labs(colour='Gene', fill='Gene') +
  facet_grid(.~amrbycountrycontinent,scales = 'free',space = 'free',drop = F) + 
  scale_y_continuous(labels = scales::percent) + guides(x =  guide_axis(angle = 45)) + 
  theme(
    panel.background = element_rect(fill='transparent'), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    panel.grid.major = element_blank(), #remove major gridlines
    panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent'), #transparent legend bg
    legend.box.background = element_rect(fill='transparent') #transparent legend panel
  )

ggsave('amrbycountry.svg', width=3240, height = 1944, units = 'px', bg = 'transparent')

\# Cas gene by country plot ####
# now create plot of cas genes by country with continent sorting
{
  dfcasbycountry <- (matrix(0, nrow=(length(allcountries)),ncol=(length(allcasgenes))))
  rownames(dfcasbycountry) <- allcountries
  colnames(dfcasbycountry) <- allcasgenes
  for(r in 1:nrow(dframesex)) {
    country <- dframesex$Country[r]
    cas_list <- categorise_cas(dframesex$Genes[r]) 
    for(n in 1:length(cas_list)) {
      if(country %in% allcountries) {
        dfcasbycountry[country,cas_list[n]] <- dfcasbycountry[country,cas_list[n]] + 1
      }
    }
  }
  casbycountrycountnorm <- c()
  casbycountrycas <- c()
  casbycountrycountry <- c()
  casbycountrycontinent <- c()
  for(r in 1:nrow(dfcasbycountry)) {
    for(c in 1:ncol(dfcasbycountry)) {
      casbycountrycountnorm <- c(casbycountrycountnorm, 
                                 (dfcasbycountry[r,c] / sum(dfcasbycountry[r,])))
      casbycountrycas <- c(casbycountrycas,colnames(dfcasbycountry)[c])
      casbycountrycountry <- c(casbycountrycountry,rownames(dfcasbycountry)[r])
      casbycountrycontinent <- c(casbycountrycontinent,categorise_who_region(
        rownames(dfcasbycountry)[r]))
    }
  }
  dfplotcasbycountry <- data.frame(casbycountrycountnorm,casbycountrycas,casbycountrycountry,casbycountrycontinent)
  }

ggplot(dfplotcasbycountry,aes(colour = casbycountrycas, fill = casbycountrycas, 
                              y = casbycountrycountnorm, x = casbycountrycountry)) + 
  geom_bar(position="stack", stat="identity",  width=.7) +
  xlab('Country') + ylab('Cas Gene Frequency') + theme_classic() +
  #theme(legend.position = 'None')  + 
  labs(colour='Gene', fill='Gene') +
  facet_grid(.~casbycountrycontinent,scales = 'free',space = 'free',drop = F) + 
  scale_y_continuous(labels = scales::percent) + guides(x =  guide_axis(angle = 45)) + 
  theme(
    panel.background = element_rect(fill='transparent'), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    panel.grid.major = element_blank(), #remove major gridlines
    panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent'), #transparent legend bg
    legend.box.background = element_rect(fill='transparent') #transparent legend panel
  )

ggsave('casbycountry.svg', width=3240, height = 1944, units = 'px', bg = 'transparent')

# AMR gene by sex network boxplot ####
{
  dfamrbysex <- (matrix(0, nrow=(length(allsexnetworks)),ncol=(length(allmechclasses))))
  rownames(dfamrbysex) <- allsexnetworks
  colnames(dfamrbysex) <- allmechclasses
  for(r in 1:nrow(dframesex)) {
    sexnet <- dframesex$Sexual.behaviour[r]
    amr_list <- amr_mechanism_class(dframesex$AMR.Gene.symbol[r]) 
    #print(amr_list)
    for(n in 1:length(amr_list)) {
      if(sexnet %in% allsexnetworks) {
        dfamrbysex[sexnet,amr_list[n]] <- dfamrbysex[sexnet,amr_list[n]] + 1
      }
    }
  }
  amrbysexcount <- c()
  amrbysexamr <- c()
  amrbysexsex <- c()
  for(r in 1:nrow(dfamrbysex)) {
    for(c in 1:ncol(dfamrbysex)) {
      amrbysexcount <- c(amrbysexcount, (dfamrbysex[r,c]))
      amrbysexamr <- c(amrbysexamr,colnames(dfamrbysex)[c])
      amrbysexsex <- c(amrbysexsex,rownames(dfamrbysex)[r])
    }
  }
  dfplotamrbysex <- data.frame(amrbysexcount,amrbysexamr,amrbysexsex)
}
ggplot(dfplotamrbysex, aes(x = amrbysexsex, y = amrbysexcount)) + 
  geom_boxplot(outlier.shape = NA) +
  ylab('Number of resistance class genes found') +
  xlab('Sex Networks') + labs(color='AMR gene') +
  ggtitle('Resistances identified by Sex Networks in Neisseria gonorrhoeae') +
  geom_jitter(aes(colour=amrbysexamr), show.legend = T) +
  coord_flip() + theme_minimal()

# recreate this boxplot with extremely low values removed

amrbysexcountoutlie <- c()
amrbysexamroutlie <- c()
amrbysexsexoutlie <- c()
dfplotamrbysexoutlie <- data.frame(dfplotamrbysex$amrbysexcount[dfplotamrbysex$amrbysexcount > 4 ],
                                   dfplotamrbysex$amrbysexamr[dfplotamrbysex$amrbysexcount > 4 ],
                                   dfplotamrbysex$amrbysexsex[dfplotamrbysex$amrbysexcount > 4 ])
colnames(dfplotamrbysexoutlie) <- c('amrbysexcountoutlie','amrbysexamroutlie','amrbysexsexoutlie')

ggplot(dfplotamrbysexoutlie, aes(x = amrbysexsexoutlie, y = amrbysexcountoutlie)) + 
  geom_boxplot(outlier.shape = NA) +
  ylab('Number of resistance class genes found') +
  xlab('Sex Networks') + labs(color='AMR gene') +
  ggtitle('Resistances identified by Sex Networks in Neisseria gonorrhoeae') +
  geom_jitter(aes(colour=amrbysexamroutlie), show.legend = F) +
  coord_flip() + theme_minimal()

# cas gene by sex network boxplot

{
  dfcasbysex <- (matrix(0, nrow=(length(allsexnetworks)),ncol=(length(allcasgenes))))
  rownames(dfcasbysex) <- allsexnetworks
  colnames(dfcasbysex) <- allcasgenes
  for(r in 1:nrow(dframesex)) {
    sexnet <- dframesex$Sexual.behaviour[r]
    cas_list <- categorise_cas(dframesex$Genes[r]) 
    #print(cas_list)
    for(n in 1:length(cas_list)) {
      if(sexnet %in% allsexnetworks) {
        dfcasbysex[sexnet,cas_list[n]] <- dfcasbysex[sexnet,cas_list[n]] + 1
      }
    }
  }
  casbysexcount <- c()
  casbysexcas <- c()
  casbysexsex <- c()
  for(r in 1:nrow(dfcasbysex)) {
    for(c in 1:ncol(dfcasbysex)) {
      casbysexcount <- c(casbysexcount, (dfcasbysex[r,c]))
      casbysexcas <- c(casbysexcas,colnames(dfcasbysex)[c])
      casbysexsex <- c(casbysexsex,rownames(dfcasbysex)[r])
    }
  }
  dfplotcasbysex <- data.frame(casbysexcount,casbysexcas,casbysexsex)
  }

ggplot(dfplotcasbysex, aes(x = casbysexsex, y = casbysexcount)) + 
  geom_boxplot(outlier.shape = NA) +
  ylab('Number of resistance class genes found') +
  xlab('Sex Networks') + labs(color='cas gene') +
  ggtitle('Resistances identified by Sex Networks in Neisseria gonorrhoeae') +
  geom_jitter(aes(colour=casbysexcas), show.legend = F) +
  coord_flip() + theme_minimal()

# AMR gene by sex network frequency stacked bar graphs ####
amrbysexnorm <- c()
for(n in 1:nrow(dfplotamrbysex)) {
  amrbysexnorm <- c(amrbysexnorm,(dfplotamrbysex$amrbysexcount[n] / sum(dfamrbysex[dfplotamrbysex$amrbysexsex[n],]) ))
}
dfplotamrbysexnorm <- data.frame(amrbysexnorm,amrbysexsex,amrbysexamr)
ggplot(dfplotamrbysexnorm,aes(fill=amrbysexamr, y=amrbysexnorm, x=amrbysexsex)) + 
  geom_bar(position='stack', stat='identity') +
  ggtitle('Relative frequency of AMR gene by Sexual Orientation') +
  xlab('Sexual Behaviour') + ylab('AMR gene frequency') +
  labs(color='Gene') + coord_flip() + theme_minimal() + 
  scale_y_continuous(labels = scales::percent) + theme(legend.position = 'None')

# cas gene by sex network frequency stacked bar graphs ####
casbysexnorm <- c()
for(n in 1:nrow(dfplotcasbysex)) {
  casbysexnorm <- c(casbysexnorm, (dfplotcasbysex$casbysexcount[n] / sum(dfcasbysex[dfplotcasbysex$casbysexsex[n],]) ))
}
dfplotcasbysexnorm <- data.frame(casbysexnorm,casbysexsex,casbysexcas)
ggplot(dfplotcasbysexnorm,aes(fill=casbysexcas, y=casbysexnorm, x=casbysexsex)) + 
  geom_bar(position='stack', stat='identity') +
  ggtitle('Relative frequency of Cas gene by Sexual Orientation') +
  xlab('Sexual Behaviour') + ylab('Cas gene frequency') +
  labs(color='Gene') + coord_flip() + theme_minimal() + 
  scale_y_continuous(labels = scales::percent) #+ theme(legend.position = 'None')

# amr by cas gene heatmap ####
{
  dfamrbycas <- data.frame(matrix(0,ncol=length(allcasgenes),nrow=length(allmechclasses)))
  rownames(dfamrbycas) <- allmechclasses
  colnames(dfamrbycas) <- allcasgenes
  for(r in 1:nrow(dframesex)) {
    amr_list <- amr_mechanism_class(dframesex$AMR.Gene.symbol[r])
    cas_list <- categorise_cas((dframesex$Genes[r]))
    for(a in 1:length(amr_list)) {
      for(c in 1:length(cas_list)) {
        dfamrbycas[amr_list[a],cas_list[c]] <- dfamrbycas[amr_list[a],cas_list[c]] + 1
      }
    }
  }
  amrbycas <- as.matrix(dfamrbycas)
  }
heatmap(amrbycas, scale='row')
heatmap(amrbycas, scale='column')
heatmap(amrbycas, scale='none')

dfamrbycasdroplow <- (dfamrbycas[1:7,1:4])
amrbycasdroplow <- as.matrix(dfamrbycasdroplow)
heatmap(amrbycasdroplow, scale='row')
heatmap(amrbycasdroplow, scale='column')
heatmap(amrbycasdroplow, scale='none')

library(RColorBrewer)
library(svglite)
coul <- colorRampPalette(brewer.pal(8, "BuPu"))(25)
ht <- heatmap(amrbycas, scale='none', col = coul )
svg("myplot.svg", width=600, height=400, bg = "transparent"); heatmap(amrbycas, scale='none', col = coul ); dev.off()

ggsave('myplot.svg', width=600, height=400, units = 'px',  bg='transparent')

svglite('myplot.svg', width=12, height=8, bg='transparent')
heatmap(amrbycas, scale='none', col = coul )
dev.off()
svglite('amrbycasdroplow.svg', width=6, height=4, bg='transparent')
heatmap(amrbycasdroplow, scale='none', col = coul )
dev.off()

# world map jittered points resistance ####
library(rgeos)
library(rworldmap)
library(maps)

# get world map
wmap <- getMap(resolution="high")

# get centroids
centroids <- gCentroid(wmap, byid=TRUE)

# get a data.frame with centroids
dfcentroids <- as.data.frame(centroids)
head(dfcentroids)
plot(centroids)

world_map <- map_data("world")
world_map <- subset(world_map, region != "Antarctica")

ggplot(dfcentroids) + geom_map(dat = world_map, map = world_map,aes(map_id = region), 
                               fill = "white",color = "#7f7f7f", size = 0.25) + 
  expand_limits(x = world_map$long, y = world_map$lat) + 
  geom_point(data = dfcentroids, aes(x = x, y = y, fill = "red", alpha = 0.8), size = 5, shape = 21) +
  guides(fill=FALSE, alpha=FALSE, size=FALSE)

# create data frame for map

dfcountrybyamr <- data.frame(matrix(0,nrows=length(allcountries),ncol=length(allmechclasses)))
rownames(dfcountrybyamr) <- allcountries
colnames(dfcountrybyamr) <- allmechclasses

amrbycountrycount <- c()
for(r in 1:nrow(dfamrbycountry)) {
  for(c in 1:ncol(dfamrbycountry)) {
    amrbycountrycount <- c(amrbycountrycount, (dfamrbycountry[r,c]))
  }
}
amrx <- c()
amry <- c()
for(n in 1:length(amrbycountrycountry)) {
  tempcountry <- amrbycountrycountry[n]
  if(tempcountry == 'USA') {
    tempcountry <- 'United States of America'
  }else if(tempcountry == 'Tanzania') {
    tempcountry <- 'United Republic of Tanzania'
  }else if(tempcountry == 'Hong Kong') {
    (tempcountry <- 'China')
  }else if(tempcountry == 'Czechia') {
    tempcountry <- 'Czech Republic'
  }else if((tempcountry == 'UK') | (tempcountry == 'Scotland') ){
    tempcountry <- 'United Kingdom'
  }else if(tempcountry == 'Guinea-Bissau') {
    tempcountry <- 'Guinea Bissau'
  }else if(tempcountry == 'Korea'){
    tempcountry <- 'South Korea'
  }else if(tempcountry == 'Caribbean') {
    tempcountry <- 'Haiti'
  }
  if(!(tempcountry %in% rownames(dfcentroids))) {
    print(tempcountry)
  }
  amrx <- c(amrx,dfcentroids[tempcountry,'x'])
  amry <- c(amry,dfcentroids[tempcountry,'y'])
}
dfplotmapamrbycountry <- data.frame(amrbycountrycount,amrbycountryamr,amrx,amry)

ggplot(dfplotmapamrbycountry) + geom_map(dat = world_map, map = world_map, aes(map_id = region),
                                         fill = 'white', color = '#7f7f7f', size = 0.25) +
  expand_limits(x = world_map$long, y = world_map$lat) + 
  geom_jitter(aes(x = amrx, y = amry, colour = amrbycountryamr, alpha=amrbycountrycount), height = 10 , width = 10 )

# heatmap of amr x cas without categorising amr genes ####
all_amr_list <- c()
for(r in 1:nrow(dframesex)) {
  all_amr_list <- unique(c(all_amr_list, unlist(strsplit(dframesex$AMR.Gene.symbol[r], ','))))
}

{
  dfamrbyuncat <- data.frame(matrix(0,ncol=length(allcasgenes),nrow=length(all_amr_list)))
  rownames(dfamrbyuncat) <- all_amr_list
  colnames(dfamrbyuncat) <- allcasgenes
  for(r in 1:nrow(dframesex)) {
    if(dframesex$AMR.Gene.symbol[r] == '' ) {
      next
    }
    amr_list <- unlist(strsplit(dframesex$AMR.Gene.symbol[r], ','))
    cas_list <- categorise_cas((dframesex$Genes[r]))
    print(r)
    for(a in 1:length(amr_list)) {
      for(c in 1:length(cas_list)) {
        dfamrbyuncat[amr_list[a],cas_list[c]] <- dfamrbyuncat[amr_list[a],cas_list[c]] + 1
      }
    }
  }
  amrbyuncat <- as.matrix(dfamrbyuncat)
}
heatmap(amrbyuncat, scale='row')
heatmap(amrbyuncat, scale='column')
heatmap(amrbyuncat, scale='none')

# heatmap of cas genes by sex network ####

heatmap(dfcasbysex, scale='row')
heatmap(dfcasbysex, scale='column')
heatmap(dfcasbysex, scale='none')

svglite('amrbyuncat.svg', width=16, height=10, bg='transparent')
heatmap(amrbyuncat, scale='none', col = coul )
dev.off()

# stacked bar graph of cas by country without normalisation
casbycountrycount <- c()
for(r in 1:nrow(dfcasbycountry)) {
  for(c in 1:ncol(dfcasbycountry)) {
    casbycountrycount <- c(casbycountrycount, (dfcasbycountry[r,c]))
  }
}
dfplotcasbycountryunnorm <- data.frame(casbycountrycount,casbycountrycas,casbycountrycountry,casbycountrycontinent)
ggplot(dfplotcasbycountryunnorm,aes(colour = casbycountrycas, fill = casbycountrycas, 
                              y = casbycountrycount, x = casbycountrycountry)) + 
  geom_bar(position="stack", stat="identity",  width=.7) +
  xlab('Country') + ylab('Cas Gene Frequency') + theme_classic() +
  theme(legend.position = 'None')  + 
  labs(fill='Gene', colour='Gene') +
  facet_grid(.~casbycountrycontinent,scales = 'free',space = 'free',drop = F) + guides(x =  guide_axis(angle = 45))

# create country plots with n= values over them ####
{
  countrycount <- data.frame(matrix(0,nrow=length(allcountries),ncol=1))
rownames(countrycount) <- allcountries
colnames(countrycount) <- c('Count')
sexcount <- data.frame(matrix(0,nrow=length(allsexnetworks),ncol=1))
rownames(sexcount) <- allsexnetworks
colnames(sexcount) <- c('Count')
countrycountstring <- c()
sexcountstring <- c()
for(r in 1:nrow(dframesex)) {
  if(!(dframesex$Country[r] == '' )) {
    countrycount[dframesex$Country[r],'Count'] <- 
      countrycount[dframesex$Country[r],'Count'] + 1
  }
  if(!(dframesex$Sexual.behaviour[r] == '' )) {
    sexcount[dframesex$Sexual.behaviour[r],'Count'] <-
      sexcount[dframesex$Sexual.behaviour[r],'Count'] + 1
  } 
}
for(n in 1:length(amrbycountrycountry)) {
  countrycountstring <- 
    c(countrycountstring, paste0('n = ', countrycount[amrbycountrycountry[n],'Count']))
}
dfplotamrbycountryn <- data.frame(amrbycountrycountnorm,amrbycountryamr,amrbycountrycountry,amrbycountrycontinent,countrycountstring)
}
ggplot(dfplotamrbycountryn,aes(colour = amrbycountryamr, fill = amrbycountryamr, y = amrbycountrycountnorm,
                              x = amrbycountrycountry)) + 
  geom_bar(position="stack", stat="identity",  width=.7) +
  xlab('Country') + ylab('Resistance Gene Frequency') + theme_classic() +
  #theme(legend.position = 'None')  + 
  labs(colour='Gene',fill='Gene') + geom_text(data = dfplotamrbycountryn, aes(label = countrycountstring, colour = 'black')) +
  facet_grid(.~amrbycountrycontinent,scales = 'free',space = 'free',drop = F) + 
  scale_y_continuous(labels = scales::percent) + guides(x =  guide_axis(angle = 45))

# copy to clipboard mac ####
write.table(sexcount, file=pipe('pbcopy'), sep='\t')

tempcontinent <- c()
for(r in 1:nrow(dframesex)) {
  tempcountry <- dframesex$Country[r]
  tempcontinent <- c(tempcontinent, categorise_who_region(tempcountry))
  if(categorise_who_region(tempcountry) == 'EMR' ) {print(tempcountry)}
}
countinent <- table(tempcontinent)
countinent

function(cas_list) {
  return_list <- c()
  if(!(cas_list == '')) {
    cas_list <- unlist(strsplit(cas_list,','))
    for(n in 1:length(cas_list)) {
      return_list <- unique(c(return_list,strsplit(cas_list[n],'_')[[1]][1]))
    }
  }
  return(return_list)
}

caspercent <- data.frame(matrix(0,nrow=1,ncol=5), row.names = c('Count'))
colnames(caspercent) <- c('No cas genes count','Cas4, Cas7, Cas8c count', 'Cas1 count', 'DEDDH count','Total count')
for(r in 1:nrow(dframesex)) {
  caspercent[1,5] <- caspercent[1,5] + 1
  if(dframesex$Genes[r] == '' ) {
    caspercent[1,1] <- caspercent[1,1] + 1
  }else {
    cas_list <- categorise_cas(dframesex$Genes[r])
    if( ('Cas4' %in% cas_list) && ('Cas7' %in% cas_list) && ('Cas8c' %in% cas_list) ) {
      caspercent[1,2] <- caspercent[1,2] + 1
    }
    if('Cas1' %in% cas_list) {
      caspercent[1,3] <- caspercent[1,3] + 1
    }
    if('DEDDh' %in% cas_list) {
      caspercent[1,4] <- caspercent[1,4] + 1
    }
  }
}
dframesex$Genes[130L]
length(dframesex$Genes[130L])

triadpercent <- caspercent[1,2] / caspercent[1,5]
cas1percent <- caspercent[1,3] / caspercent[1,5]
deddpercent <- caspercent[1,4] / caspercent[1,5]

triadpercent 
cas1percent 
deddpercent 

countrieswithdeddh <- c()
for(r in 1:nrow(dframesex)) {
  cas_list <- categorise_cas(dframesex$Genes[r])
  if('DEDDh' %in% cas_list) {
    countrieswithdeddh <- c(countrieswithdeddh,dframesex$Country[r])
  }
  countrieswithdeddh <- unique(countrieswithdeddh)
}
deddhframe <- data.frame(matrix(0,nrow=length(countrieswithdeddh),ncol=1))
rownames(deddhframe) <- countrieswithdeddh
for(r in 1:nrow(dframesex)) {
  cas_list <- categorise_cas(dframesex$Genes[r])
  if(!(dframesex$Country[r] == '' )) {
    if('DEDDh' %in% cas_list) {
      deddhframe[dframesex$Country[r],1] <- deddhframe[dframesex$Country[r],1] + 1
    }
  }
}
colnames(deddhframe) <- c('Count')
deddhfram <- deddhframe[-3,]
deddhframe[3,]
deddhfram

#reordering test ####
d <- data.frame(
  y=c(0.1, 0.2, 0.7),
  cat = factor(c('No', 'Yes', 'NA'), levels = c('NA', 'Yes', 'No')))

p1 <- ggplot(d, aes(x=1, y=y, fill=cat)) +
  geom_bar(stat='identity')

# Change order of rows
p2 <- ggplot(d[c(2, 3, 1), ], aes(x=1, y=y, fill=cat)) +
  geom_bar(stat='identity')

# Change order of levels
d$cat2 <- relevel(d$cat, 'Yes')
d$cat2 <- relevel(d$cat, 'No')
p3 <- ggplot(d, aes(x=1, y=y, fill=cat2)) +
  geom_bar(stat='identity') 

grid.arrange(p1, p2, p3, ncol=3)

ggplot(d, aes(x=1, y=y, fill=cat)) +
  geom_bar(stat='identity')

# get original levels
levels(as.factor(dfplotamrbycountryreorder$amrbycountryamr))
# create vector to take new levels
newlevels <- levels(as.factor(dfplotamrbycountry$amrbycountryamr))
# create vector length of original vector and permute however you want
map <- c(16,2,3,4,5,6,7,8,9,10,11,12,13,14,15,1,17,18,19,20,21,22,23,24,25)
# now new levels vector is ordered by that map
newlevels <- newlevels[order(map)]
# in ggplot replace fill and or colour = x with = factor(x,levels=newlevels)

ggplot(dfplotamrbycountryreorder,aes(colour = factor(amrbycountryamr, levels=newlevels), fill = factor(amrbycountryamr, levels=newlevels), y = amrbycountrycountnorm,
                              x = amrbycountrycountry)) + 
  geom_bar(position="stack", stat="identity",  width=.7) +
  xlab('Country') + ylab('Resistance Gene Frequency') + theme_classic() +
  #theme(legend.position = 'None')  + 
  labs(colour='Gene', fill='Gene') +
  facet_grid(.~amrbycountrycontinent,scales = 'free',space = 'free',drop = F) + 
  scale_y_continuous(labels = scales::percent) + guides(x =  guide_axis(angle = 45)) + 
  theme(
    panel.background = element_rect(fill='transparent'), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    panel.grid.major = element_blank(), #remove major gridlines
    panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent'), #transparent legend bg
    legend.box.background = element_rect(fill='transparent') #transparent legend panel
  )

ggsave('amrbycountry.svg', width=3240, height = 1944, units = 'px', bg = 'transparent')
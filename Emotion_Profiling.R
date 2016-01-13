##### Construct dictionary
emo.dic <- read.csv("emotion_chunks.csv", header=T, colClasses="character")
# emo.dic[1, 1]
for(i in 1:nrow(emo.dic)){
  if(grepl("^\t|NA" ,emo.dic[i, 1])) {
    emo.dic[i, 1] <- NA
  } else {
    emo.dic[i, 1] <- gsub("\t\\d\t", "\t\t", emo.dic[i,1])
    emo.dic[i, 1] <- gsub("\t$", "\tX", emo.dic[i,1])
    emo.dic[i, 1] <- gsub(" ", "", emo.dic[i,1])
    emo.dic[i, 1] <- gsub("\t\t", " ", emo.dic[i, 1])
    #     emo.dic[i, 1] <- substr(emo.dic[i, 1], start=1, stop=regexpr("\t", emo.dic[i, 1])-1)
  }
}
# emo.dic[156, 1]
# emo.dic[8081, 1]
# emo.dic[8109, 1] <- gsub("\t\\d\t", "\t\t", emo.dic[8109,1])
# complete.cases(emo.dic[8101:8110, 1])
emo_clean <- emo.dic[complete.cases(emo.dic), ]
# if(grepl("^\t|NA" ,emo.dic[8081, 1])) {
#   emo.dic[8081, 1] <- NA
# }
write.table(emo_clean, "emo_dic.txt", quote=F, col.names=F , row.names=F)
p_dic <- emo_clean[grepl(" P$", emo_clean)]
write.table(p_dic, "p_dic.txt", quote=F, col.names=F , row.names=F)
n_dic <- emo_clean[grepl(" N$", emo_clean)]
write.table(n_dic, "n_dic.txt", quote=F, col.names=F , row.names=F)

library(jiebaR)
# ShowDictPath()
# emo.cut <- function(x) {
#   tag_data <- worker(type="tag", user="emo_dic.txt") <= x
#   return (sum(names(tag_data)=="P"))
# }
emo.cut <- worker(type="tag", user="emo_dic.txt")
auto_polar <- function(x) {
  if (grepl("^\\.+$|^\\\\+|^/+$", x)){
    return ("-1")
  } else {
  tag_data <- emo.cut <= x
  count_P <- sum(names(tag_data)=="P")
  count_N <- sum(names(tag_data)=="N")
  return (count_P - count_N)
  }
}

# tt <- comments03[6,2]
# p_cut <- worker(type="tag", user="emo_dic.txt")
# p_cut<=tt


##### Read Data
setwd("comments/")
getwd()

### All Comments between 11/17-12/31 (on 12/31)
frame <- list.files(getwd())
# frame[length(frame)]
# length(frame)
# test <- read.csv(frame[234], header=T)
# test[1, ]
# as.character(comments[2,1])
cand_01 <- "10150145806225128" # 朱立倫
cand_02 <- "46251501064" # 蔡英文
cand_031 <- "491399324358361" # 宋楚瑜找朋友
cand_032 <- "781585891901624" # 宋楚瑜
comments01 <- comments02 <- comments031 <- comments032 <- matrix(ncol=2)
# aa <- cbind(as.character(test$parent_id), as.character(test$message))
# aa[1, ]

### all comments in posts during 11/17~12/31
id <- cand <- article <- comments <- matrix(ncol=1)
for (i in 1:length(frame)){
  aa <- read.csv(frame[i], header=T)
  ab <- as.character(aa$message)
  for (j in 1:length(ab)){
    ab[j] <- auto_polar(ab[j])
  }
  comments[i] <- sum(as.numeric(ab))
  id[i] <- substr(frame[i], start=regexpr("s", frame[i])+1, stop=regexpr(".csv", frame[i])-1)
  ac <- substr(frame[i], start=regexpr("s", frame[i])+1, stop=regexpr("_", frame[i])-1)
  if (ac == cand_01){
    cand[i] <- "朱立倫"
    } else if (ac == cand_02){
      cand[i] <- "蔡英文"
      } else {
        cand[i] <- "宋楚瑜"
      }
  article[i] <- substr(frame[i], start=regexpr("_", frame[i])+1, stop=regexpr(".csv", frame[i])-1)
}
# comments
all_comm <- cbind(cbind(cbind(id, cand), article), comments)
# head(all_comm)
# write.csv(all_comm, "all_comm.csv")

#### Statistics of emotions
library(data.table)
all_comm_dt <- as.data.table(all_comm)
# head(all_comm_dt)

comm_ana <- all_comm_dt[, list(
  pos_emo = if (as.numeric(comments)>0) 1 else 0,
  neg_emo = if (as.numeric(comments)<0) 1 else 0),
  by="id,cand,comments"]

comm_pol <- comm_ana[, list(
  pos = sum(pos_emo),
  neg = sum(neg_emo)),
  by=cand]

### After second debate
# deb01 <- c("10150145806225128_10156492872275128",
#            "10150145806225128_10156492570450128")
# deb02 <- c("46251501064_10153099145106065",
#            "46251501064_10153099000421065",
#            "46251501064_10153098729726065",
#            "46251501064_10153098721506065",
#            "46251501064_10153098595696065")
# deb03 <- c("781585891901624_1011793182214226",
#            "781585891901624_1011747808885430",
#            "781585891901624_1011729438887267",
#            "781585891901624_1011695832223961",
#            "781585891901624_1011655892227955",
#            "781585891901624_1011642185562659")

# for(i in 1:length(frame)){
#   aa <- read.csv(frame[i], header=T)
#   ab <- cbind(as.character(aa$parent_id), as.character(aa$message))
#   cand_t <- substr(ab[1, 1], start=1, stop=regexpr("_", ab[1, 1])-1)
#   if (cand_t == cand_01){
#     comments01 <- rbind(comments01, ab)
#   } else if (cand_t == cand_02){
#     comments02 <- rbind(comments02, ab)
#   } else if (cand_t == cand_031){
#     comments031 <- rbind(comments031, ab)
#   } else {
#     comments032 <- rbind(comments032, ab)
#   }
# }
# ab[1,1]
# bb <- rbind(aa, comments01)
# frame[473]

### Comments of top 3 of like, comment, and share per candidarte
top01 <- c("comments10150145806225128_10156422751305128.csv",
           "comments10150145806225128_10156326610565128.csv",
           "comments10150145806225128_10156308286925128.csv",
           "comments10150145806225128_10156241523030128.csv",
           "comments10150145806225128_10156250715705128.csv",
           "comments10150145806225128_10156406095440128.csv",
           "comments10150145806225128_10156241523030128.csv",
           "comments10150145806225128_10156375213540128.csv",
           "comments10150145806225128_10156462045700128.csv")

top02 <- c("comments46251501064_10153009060561065.csv",
           "comments46251501064_10153019685091065.csv",
           "comments46251501064_10152974525636065.csv",
#            "comments46251501064_324288307695567.csv",
#            "comments46251501064_131286897234362.csv",
           "comments46251501064_10153009060561065.csv",
           "comments46251501064_10153091050271065.csv",
           "comments46251501064_10153009060561065.csv",
           "comments46251501064_10153061583281065.csv")

top03 <- c("comments781585891901624_1001310346595843.csv",
           "comments781585891901624_1003682823025262.csv",
           "comments781585891901624_1009515102442034.csv",
           "comments781585891901624_1001310346595843.csv",
           "comments781585891901624_1008291685897709.csv",
           "comments781585891901624_1005648952828649.csv",
           "comments781585891901624_1001381746588703.csv",
           "comments781585891901624_1005023252891219.csv",
           "comments781585891901624_1008906529169558.csv")

comments01 <- matrix(ncol=1)
for (i in 1:length(top01)){
  aa <- read.csv(top01[i], header=T)
  ab <- as.character(aa$message)
  for (j in 1:length(ab)){
    ab[j] <- auto_polar(ab[j])
  }
  comments01[i] <- sum(as.numeric(ab))
}
# aa <- read.csv(top01[9], header=T)
# auto_polar(ab[11189])
# ab[11189]
# comments01

comments02 <- matrix(ncol=1)
for (i in 1:length(top02)){
  aa <- read.csv(top02[i], header=T)
  ab <- as.character(aa$message)
  for (j in 1:length(ab)){
    ab[j] <- auto_polar(ab[j])
  }
  comments02[i] <- sum(as.numeric(ab))
}
# aa <- read.csv(top01[9], header=T)
# auto_polar(ab[11189])
# ab[11189]
# comments02

comments03 <- matrix(ncol=1)
# aa <- lapply(top03, read.csv, header=T)
for (i in 1:length(top03)){
  aa <- read.csv(top03[i], header=T)
  ab <- as.character(aa$message)
  for (j in 1:length(ab)){
    ab[j] <- auto_polar(ab[j])
  }
  comments03[i] <- sum(as.numeric(ab))
}

# sum(as.numeric(ab))
# comments03
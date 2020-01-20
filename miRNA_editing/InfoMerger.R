#parameters
folder<-"~/Documents/miRmedon/"
filenames<-list.dirs(folder, full.names = FALSE, recursive = FALSE)
# editedTableName<-"results.txt"
crtTableName<-"total.crt_counts.txt"
# graphName<-"histogram.pdf"
# 
# ####################################
# #main loop
# ####################################
# 
# editedFile<-data.frame(Sample = character(),
#                     type = character(),
#                     miRNA = character(),
#                     position = integer(),
#                     edited = numeric(),
#                     unedited = numeric(),
#                     editing_level = numeric(),
#                     LCI = numeric(),
#                     UCI = numeric(),
#                     p_value = numeric(),
#                     stringsAsFactors = FALSE)
# 
crtFile<-data.frame(Sample=character(),
                    type=character(),
                    miRNA=character(),
                    count=numeric(),
                    sequence=character(),
                    editing_info=character(),
                    stringsAsFactors = FALSE)
for(i in 1:length(filenames))
{
  # file<-read.delim(paste0(folder, filenames[i], "/", filenames[i], ".editing_info.txt"), header=TRUE, sep="\t", stringsAsFactors = FALSE)
  # tryCatch(
  # {
  #   file[ , 3:10]<-file[ , 1:8]
  #   file[ , 1]<-filenames[i]
  #   file[ ,2]<-if(i <= 44) "CLL" else "B_Cell"
  #   editedFile<-rbind(editedFile, file)
  # }, error=function(e){
  #   print(paste0("Error! Sample ", filenames[i], " has no data! Skipping sample!"))
  #   })
  
  tryCatch(
  {
    file<-read.delim(paste0(folder, filenames[i], "/", filenames[i], ".crt_counts.txt"), header=TRUE, sep="\t", stringsAsFactors = FALSE)
    keep<-grep("_e", file$miRNA_form)
    file<-file[keep, ]
    tryCatch(
    {
      file[, 3:6]<-file[, 1:4]
      file[, 1]<-filenames[i]
      file[, 2]<-if(i <= 44) "CLL" else "B_Cell"
      crtFile<-rbind(crtFile, file)
    }, error=function(e){
     warning(paste0("Warning! Sample ", filenames[i], " contains no data matching the criteria! Skipping Sample!")) 
    })
  }, error=function(e){
    warning(paste0("Warning! File ", filenames[i], ".crt_counts.txt does not exist! Skipping file!"))
  })
}
# colnames(editedFile)<-c("Sample", "Type", "miRNA", "Position", "Edited", "Unedited", "Editing_Level", "LCI", "UCI", "p_value")
# keep<-which((editedFile$Edited >= 5.0) & (editedFile$Editing_Level >= 0.01))
# editedFile<-editedFile[keep, ]
# #write.table(editedFile, paste0(folder, editedTableName), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)
# 

colnames(crtFile)<-c("Sample", "Type", "miRNA", "Count", "Sequence", "Editing_Info")
keep<-which(crtFile$Count >= 5.0)
crtFile<-crtFile[keep, ]
write.table(crtFile, paste0(folder, crtTableName), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)
# #################
# #Create Diagram
# #################
# graphData<-editedFile[row.names(unique(editedFile[ , 1:3])), ]
# graph<-ggplot(graphData, aes(x=miRNA, color = Type, fill = Type)) + 
#   geom_bar(position = position_dodge()) + 
#   theme(axis.text.x = element_text(angle = 90))
# pdf(paste0(folder, graphName))
# print(graph)
# dev.off()
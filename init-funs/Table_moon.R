Table.moon <- function(df = df, Label = Label, ...) {
  browser()
  df[, 1] <- gsub(" ", "", df[, 1])
  idx1 <- which(df[, 1] %in% names(Label))
  # rowname.int <- base::intersect(df[, 1], names(Label))
  
  for (i in idx1) {
    idx2 <- which(df[i, 1] == names(Label))
    df[i, 1] <- as.character(Label[idx2])
  }
  
  # df[, 1] <- gsub("^-Y{1}", "&nbsp;&nbsp;&nbsp;Yes", df[, 1]); 
  # df[, 1] <- gsub("^-N{1}(?!.*o)", "&nbsp;&nbsp;&nbsp;No", df[, 1], perl = T)
  # df[, 1] <- gsub("^-", "&nbsp;&nbsp;&nbsp;", df[, 1])
  df[, 1] <- gsub("^-", "    ", df[, 1])

  Header <- names(df); Header[NROW(Header)] <- "P-value"
  Header <- paste("\\textbf{", Header, "}", sep = ""); Header[1] <- ""
  NHeader <- as.numeric(gsub("\\(|N=|\\)", "", df[1, ])); NHeader <- NHeader[complete.cases(NHeader)]
  N <- sum(NHeader);  Ntxt <- NHeader
 
  for (i in 1:NROW(NHeader)) Ntxt[i] <- sprintf("%i (%.1f %%)", NHeader[i], NHeader[i]/N*100)
  df[1, c(1, length(NHeader)+1)] <- c("N", Ntxt)
  
  # df <- apply(df, 2, function(x) gsub("±", "$\\\\pm$", x))
  # df <- apply(df, 2, function(x) gsub("\\%", " \\\\%", x))
  df <- data.frame(df)
  return(df)
}


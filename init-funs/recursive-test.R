x <- 0
system.time(for (i in 1:10000000) { x <- x + i})
system.time(sum(1:10000000))


aa <- function(n) {
  if (n <= 1) {
    return(n)
  } else {
    return(n + aa(n - 1)) 
  }
}
aa(4)

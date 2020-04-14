# 문자열과 정규표현식 {#string-regexp}




R은 주로 수치형 벡터를 기반으로 거의 모든 연산이 행해지지만, 문자 데이터는 꽤, 빈번하게 조우한다.


The primary R functions for dealing with regular expressions are

grep(), grepl(): These functions search for matches of a regular expression/pattern in a character vector. grep() returns the indices into the character vector that contain a match or the specific strings that happen to have the match. grepl() returns a TRUE/FALSE vector indicating which elements of the character vector contain a match

regexpr(), gregexpr(): Search a character vector for regular expression matches and return the indices of the string where the match begins and the length of the match

sub(), gsub(): Search a character vector for regular expression matches and replace that match with another string

regexec(): This function searches a character vector for a regular expression, much like regexpr(), but it will additionally return the locations of any parenthesized sub-expressions. Probably easier to explain through demonstration.


For this chapter, we will use a running example using data from homicides in Baltimore City. The Baltimore Sun newspaper collects information on all homicides that occur in the city (it also reports on many of them). That data is collected and presented in a map that is publically available. I encourage you to go look at the web site/map to get a sense of what kinds of data are presented there. Unfortunately, the data on the web site are not particularly amenable to analysis, so I’ve scraped the data and put it in a separate file. The data in this file contain data from January 2007 to October 2013.

Here is an excerpt of the Baltimore City homicides dataset:

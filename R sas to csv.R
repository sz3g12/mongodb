setwd('/Users/apple/Documents/newdata')
install.packages('haven')
library(haven)
# read in all the 2020 data
country = read_sas('notrealnamecountry.sas7bdat')
exphscode2020 = read_sas('notrealnamehscode2020.sas7bdat')
export2020 = read_sas('notrealnameexport2020.sas7bdat')
imphscode2020 = read_sas('notrealnameimphscode2020.sas7bdat')
import2020 = read_sas('notrealnameimport2020.sas7bdat')
classification = read_sas('notrealnameclassification.sas7bdat')
# connect to sqlite
# install.packages("RSQLite")
library(RSQLite)

# R link to SQLite 
# https://www.datacamp.com/community/tutorials/sqlite-in-r
# Create a connection to our new database, trade.db
# check that the .db file has been created on your working directory
conn <- dbConnect(RSQLite::SQLite(), "trade.db")

# Write the mtcars dataset into a table names country
dbWriteTable(conn, "country", country)
# List all the tables available in the database
dbListTables(conn)

# Get the car names and horsepower starting with M that have 6 or 8 cylinders
dbGetQuery(conn,"SELECT * FROM country
                 LIMIT 10")

# Write the mtcars dataset into a table names mtcars_data
dbWriteTable(conn, "exphscode2020", exphscode2020)
dbWriteTable(conn, "export2020", export2020)
dbWriteTable(conn, "imphscode2020", imphscode2020)
dbWriteTable(conn, "import2020", import2020)
dbWriteTable(conn, "classification", classification)

dbListTables(conn)

# get sample data to check
# write.csv(country, 'sample data/country.csv')
write.csv(exphscode2020, 'data/exphscode2020.csv')
write.csv(export2020, 'data/export2020.csv')
write.csv(imphscode2020, 'data/imphscode2020.csv')
write.csv(import2020, 'data/import2020.csv')
write.csv(classification, 'data/classification.csv')


# Aggregate shipments by port of unlading, HS Code, and consignee
shipment_by_port = dbGetQuery(conn, "select imp2020.portOfUnlading
, imp2020.conName
, hs2020.hsCode
, sum(imp2020.weightKg) as totalKG
, count(imp2020.notrealnameid) as NumShipments
--, imp2020.quantity
from import2020 imp2020
join imphscode2020 hs2020 on hs2020.notrealnameId = imp2020.notrealnameId
where 1=1
and imp2020.conName is not null
group by imp2020.portOfUnlading, hs2020.hsCode, imp2020.conName
order by imp2020.portOfUnlading, imp2020.conName, hs2020.hsCode"
)

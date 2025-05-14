# Install required packages only if missing
if (!require(tidyverse)) install.packages("tidyverse", dependencies=TRUE)
if (!require(car)) install.packages("car", dependencies=TRUE)

# Load libraries
library(tidyverse)
library(car)

# Load sales data 
sales_cities <- read_csv("data/project.sales.cities.csv")
sales_zipcodes <- read_csv("data/project.sales.zipcodes.csv")
sales_counties <- read_csv("data/project.sales.counties.csv")

# Load ACS (demographic & economic) data
acs_zipcodes <- read_csv("data/project.acs.zipcodes.csv")
acs_cities <- read_csv("data/project.acs.cities.csv")
acs_counties <- read_csv("data/project.acs.counties.csv")

# Check structure 
glimpse(acs_zipcodes)
glimpse(acs_cities)
glimpse(acs_counties)

# Check for matching column names before merging
colnames(sales_zipcodes)
colnames(acs_zipcodes)
colnames(sales_cities)
colnames(acs_cities)
colnames(sales_counties)
colnames(acs_counties)

# Merge sales & ACS data by common columns 
merged_zipcodes <- sales_zipcodes %>% left_join(acs_zipcodes, by = "zipcode")
merged_cities <- sales_cities %>% left_join(acs_cities, by = "city")
merged_counties <- sales_counties %>% left_join(acs_counties, by = "county")

# Verify the merge worked 
head(merged_zipcodes)
glimpse(merged_zipcodes)

# Check for missing values 
sum(is.na(merged_zipcodes))
sum(is.na(merged_cities))
sum(is.na(merged_counties))

# Run a simple regression model 
model <- lm(sale.dollars ~ income, data = merged_zipcodes, na.action = na.exclude)
summary(model)

# Run a multiple regression model 
model_multi <- lm(sale.dollars ~ income + bachelor + unemployment, data = merged_zipcodes, na.action = na.exclude)
summary(model_multi)

# Check correlation between predictors
vif(model_multi)

# Prepare regression dataset
regression_data <- merged_zipcodes %>%
  select(zipcode, category, sale.dollars, income, bachelor, unemployment, population) %>%
  rename(sales = sale.dollars)

# Convert population to numeric and handle missing values
regression_data <- regression_data %>%
  mutate(population = as.numeric(as.character(population))) %>%
  filter(!is.na(population) & population > 0)

# Compute per capita liquor sales
regression_data <- regression_data %>%
  mutate(sales_per_capita = sales / population)

# Check Total Liquor Sales by Income Level 
regression_data %>%
  group_by(income_bracket = cut(income, breaks = 5)) %>%
  summarize(total_sales = sum(sales, na.rm = TRUE))

# Visualizations
ggplot(regression_data, aes(x = income, y = sales)) +
  geom_point() +
  geom_smooth(method = "lm", color = "blue") +
  labs(title = "Income vs. Liquor Sales", x = "Median Income", y = "Total Liquor Sales")

ggplot(regression_data, aes(x = bachelor, y = sales)) +
  geom_point() +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Education Level vs. Liquor Sales", x = "Bachelor’s Degree %", y = "Total Liquor Sales")

ggplot(regression_data, aes(x = unemployment, y = sales)) +
  geom_point() +
  geom_smooth(method = "lm", color = "green") +
  labs(title = "Unemployment vs. Liquor Sales", x = "Unemployment Rate", y = "Total Liquor Sales")

ggplot(regression_data, aes(x = income, y = sales_per_capita)) +
  geom_point() +
  geom_smooth(method = "lm", color = "purple") +
  labs(title = "Income vs. Per Capita Liquor Sales", x = "Median Income", y = "Liquor Sales Per Capita")

category_sales <- regression_data %>%
  group_by(category) %>%
  summarize(avg_sales = mean(sales, na.rm = TRUE)) %>%
  arrange(desc(avg_sales))

ggplot(category_sales, aes(x = reorder(category, -avg_sales), y = avg_sales)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Average Liquor Sales by Category", x = "Liquor Category", y = "Average Sales") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(regression_data, aes(x = income, y = sales, color = category)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Income vs. Liquor Sales by Category", x = "Median Income", y = "Total Liquor Sales") +
  theme_minimal()

model_log <- lm(log(sales) ~ income + bachelor + unemployment, data = regression_data, na.action = na.exclude)
summary(model_log)

ggplot(regression_data %>% filter(sales > 0), aes(x = income, y = log(sales))) +
  geom_point() +
  geom_smooth(method = "lm", color = "darkred") +
  labs(title = "Income vs. Log-Transformed Liquor Sales", x = "Median Income", y = "Log(Total Liquor Sales)")

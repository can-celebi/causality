# Quiz Score Distribution Analysis
library(ggplot2)

# Create the data: individual scores for each student
scores <- c(
  rep(1, 2),  # 2 students got 1 point
  rep(2, 1),  # 1 student got 2 points
  rep(3, 2),  # 2 students got 3 points
  rep(4, 4),  # 4 students got 4 points
  rep(5, 5),  # 5 students got 5 points
  rep(6, 3)   # 3 students got 6 points
)

# Create a data frame
quiz_data <- data.frame(score = scores)

# Summary statistics
cat("=== Quiz Summary Statistics ===\n")
cat("Number of students:", length(scores), "\n")
cat("Mean score:", round(mean(scores), 2), "\n")
cat("Median score:", median(scores), "\n")
cat("Standard deviation:", round(sd(scores), 2), "\n")
cat("Min score:", min(scores), "\n")
cat("Max score:", max(scores), "\n")
cat("\nScore distribution:\n")
print(table(scores))

# Create the bar plot
ggplot(quiz_data, aes(x = factor(score))) +
  geom_bar(fill = "steelblue", color = "black", width = 0.7) +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.5) +
  scale_x_discrete(limits = factor(0:6)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Quiz Score Distribution",
    subtitle = paste("n =", length(scores), "| Mean =", round(mean(scores), 2),
                     "| Median =", median(scores)),
    x = "Score (points)",
    y = "Number of Students"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 10),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )


cmd <- "cd '/var/rprojects/EEA/EEA_vocabulary/' && /usr/lib/R/bin/Rscript './check_vocabulary_weekly.R'  >> './check_vocabulary_weekly.log' 2>&1"

cron_add(command = cmd, frequency = 'daily', at = '09:00', days_of_week = 1, 
         id = 'check_EEA_vocabulary', 
         description = 'This downloads this weeks vocabulary and checks if there are any missing entries compared with last week',
         tags = c('EEA', 'vocabulary', 'weekly'))

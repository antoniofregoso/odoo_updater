#!/bin/bash
# This script will update odoo

#database
db_name="odoo18"
# Log file
log_file="update_odoo.log"
# Function to get the current date and time
timestamp() {
date +"%Y-%m-%d %H:%M:%S"
}
#repos Add here the repos you want to update
repos=(
    "odoo"
    "web"
    "sale-workflow"
    "ecommerce"
    )

    update_repos() {
        local repo_dir=$1
        echo "$(timestamp) - Updating repo in $repo_dir..." | tee -a "$log_file"
        # Change to the repository directory
        cd "$repo_dir" || { echo "$(timestamp) - Error: Unable to access directory $repo_dir" | tee -a "$log_file"; return 1; }
        # Check if it is a git repository
        if [ ! -d ".git" ]; then
            echo "$(timestamp) - Error: $repo_dir it is not a git repository" | tee -a "$log_file" | tee -a "$log_file"
            return 1
        fi
        
        # Pull the latest changes
        git pull || { echo "$(timestamp) - Error: git pull failed at $repo_dir"; return 1; }
        
        echo "$(timestamp) - Repository in $repo_dir updated successfully." | tee -a "$log_file"
        
        # Return to the previous directory
        cd - > /dev/null
        return 0
    }

# Delete the log file if it exists
[ -f "$log_file" ] && rm "$log_file"

# Iterate over the list of repositories and update each one
for repo in "${repos[@]}"; do
update_repos "$repo"
done

echo "$(timestamp) - Repository update completed." | tee -a "$log_file"
# Activate the virtual environment
source .venv/bin/activate
# Update the Odoo database
echo "$(timestamp) - Updating Odoo database..." | tee -a "$log_file"
./odoo/odoo-bin -c odoo.conf  -u all -d $db_name --stop-after-init 2>&1 | tee -a $log_file
if [ $? -ne 0 ]; then
        echo "$(timestamp) - Error: Database update failed" | tee -a "$log_file"
        deactivate
        return 1
fi

echo "$(timestamp) - Odoo database updated successfully." | tee -a "$log_file"
# Deactivate the virtual environment
echo "$(timestamp) - Deactivating the virtual environment..." | tee -a "$log_file"
deactivate

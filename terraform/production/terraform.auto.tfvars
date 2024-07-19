# Default billing account
billing_account_id = "01CF48-052610-ECCCA3"
default_region     = "us-west1"
environment        = "production"
# TODO update me
folder_id = "folders/<product-folder-id>"
# Please keep the dl- prefix to reduce the risk of conflict and to enable reusing GHA workflows that take
# the environment as a variable
# NOTE: project_name must be 4 to 30 characters with lowercase and uppercase letters, numbers, hyphen, single-quote, double-quote, space, and exclamation point.
project_name          = "dl-<product_name>-production"
product_name          = "<product_name>"
product_friendly_name = "<Product Friendly Name>"

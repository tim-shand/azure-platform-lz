# Provide subscription ID names per stack. Used with data call to resolve name to ID.
# Uses the "display_name_contains" argument to filter all subscriptions matching the provided value. 
# This keeps subscription IDs out of the code base. Used ONCE to get ID values.
platform_subscription_identifiers = {
  mgt = "platform-plz-sub", # Management stack subscription name value. String value unique to the target subscription.
  gov = "platform-plz-sub", # Governance stack subscription name value. String value unique to the target subscription.
  con = "platform-plz-sub"  # Connectivity stack subscription name value. String value unique to the target subscription.
}

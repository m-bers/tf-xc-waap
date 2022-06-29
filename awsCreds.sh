# Script to retrieve ephemeral AWS account credentials from UDF API

printf "[default]\naws_access_key_id=" > ~/.aws/credentials
curl -s 10.1.1.1/cloudAccounts | jq '.cloudAccounts[0]' | jq -r ' .apiKey' >> ~/.aws/credentials
printf "aws_secret_access_key=" >> ~/.aws/credentials
curl -s 10.1.1.1/cloudAccounts | jq '.cloudAccounts[0]' | jq -r ' .apiSecret' >> ~/.aws/credentials
printf "[default]\nregion=us-west-2" > ~/.aws/config
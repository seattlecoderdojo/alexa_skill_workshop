# set up AWS using the SDK
# https://github.com/aws/aws-sdk-rails#usage

keys = Rails.application.credentials[:aws]

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(keys[:access_key_id], keys[:secret_access_key])
})

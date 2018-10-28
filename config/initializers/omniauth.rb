Rails.application.config.middleware.use OmniAuth::Builder do
  provider :amazon,
    'amzn1.application-oa2-client.8ab3350dc66e454995bf763a50b67d04',
    Rails.application.credentials.amazon[:auth_key],
    { scope: 'profile' }
end

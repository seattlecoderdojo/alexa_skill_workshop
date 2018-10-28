class IndexController < ApplicationController
  def index

    # create a signin link
    unless current_user.nil?
      require 'open-uri'
      retries ||= 0

      signin_url = 'https://signin.aws.amazon.com/federation'
      role = "arn:aws:iam::051946164308:role/#{@user.role}"
      console_url = "https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/#{@user.role}"

      begin
        sts = Aws::STS::Client.new
        creds = sts.assume_role(role_arn: role,
                                role_session_name: @user.name,
                                external_id: @user.uid).credentials
        session = {
          sessionId: creds.access_key_id,
          sessionKey: creds.secret_access_key,
          sessionToken: creds.session_token
        }.to_json

        get_uri = "#{signin_url}?Action=getSigninToken&SessionType=json&Session=#{CGI.escape(session)}"

        signin_token = JSON.parse(URI.parse(get_uri).read)['SigninToken']
        signin_token_param = "&SigninToken=#{CGI.escape(signin_token)}"

        issuer_param = "&Issuer=#{CGI.escape('https://alexa.seattlecoderdojo.org')}"
        destination_param = "&Destination=#{CGI.escape(console_url)}"
        duration_param = "&SessionDuration=28800"

        @login_uri = "#{signin_url}?Action=login#{signin_token_param}#{issuer_param}#{destination_param}#{duration_param}"
      rescue Aws::STS::Errors::AccessDenied => e
        sleep 5
        retry if (retries += 1) < 3

        raise e
      end


    end

  end
end

class SessionsController < ApplicationController
  def create
    # grab or persist the user
    @user = User.where(:provider => auth['provider'],
                       :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    # update session
    session[:uid] = auth['uid']
    session[:provider] = auth['provider']

    # if the role doesn't exist for this user, create it
    # (and also attach a role)
    # (and also create a lambda function for them)
    if @user.role.nil?
      # grab the assume role policy
      @uid = @user.uid
      assume_role_policy = render_to_string('iam/assume_role_policy', layout: false)

      # create the role
      name = "dojo-#{@user.name}"
      iam = Aws::IAM::Client.new
      resp = iam.create_role(role_name: name,
                             assume_role_policy_document: assume_role_policy,
                             max_session_duration: 7200)
      @user.role = resp.role.role_name
      @user.save!

      @function_name = @user.role
      role_policy = render_to_string('iam/policy', layout: false)

      # put the policy inline on this role
      iam.put_role_policy(policy_document: role_policy,
                          policy_name: "#{@user.role}-policy",
                          role_name: @user.role)


      # cool, now create their lambda function
      l = Aws::Lambda::Client.new
      l.create_function(function_name: @function_name,
                         runtime: 'nodejs6.10',
                         role: 'arn:aws:iam::051946164308:role/service-role/dojo-lambda-role',
                         handler: 'index.handler',
                         code: {s3_bucket: 'scdojo1',
                                s3_key: 'blah1-993126f9-5334-490a-aded-9dacdb3caf17'},
                         description: 'your alexa skill\'s code')
    end

    redirect_to '/'
  end

  protected

  def auth
    request.env['omniauth.auth']
  end
end

require 'spec_helper'

describe "Users" do
  describe "GET /users" do
    context "when not sign in" do
      before do
        get users_path
      end
      subject { response }
      # its(:status) { should be(302) }
      it "redirect to sign in page" do
        # user have no permissions, by Cancan
        expect(response).to redirect_to(root_path)
        follow_redirect!
        # user not sign in, by devise
        expect(response).to redirect_to(user_session_path)
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end

    context "when sign in as admin" do
      before do
        @user = sign_in_as_admin
      end
      subject { response }
      before do
        get users_path
      end
      # its(:status) { should be(200) }
      it "render template index" do
        expect(response).to render_template(:index)
      end
    end
  end
end

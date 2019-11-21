require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/controllers/users_controller_test.rb
class UsersControllerTest < ActionDispatch::IntegrationTest
  test "gets signup page" do
    get users_new_url
    assert_response :success
  end

  describe "when creating a new user" do
    test "redirects for login" do
      post "/users/new", params: { user: { name: "new user", email: "newuser@dafox.com", password: "secret", password_confirmation: "secret" } }
      follow_redirect!
      assert_equal "/login", path
    end

    test "creates unverified user record" do
      post "/users/new", params: { user: { name: "new user", email: "newuser@dafox.com", password: "secret", password_confirmation: "secret" } }
      assert_equal "newuser@dafox.com", User.last.email
      refute User.last.verified
    end

    describe "when there are user model errors" do
      test "reloads new user page with error information" do
        post "/users/new", params: { user: { name: "new user", email: "newuser@dafox.com", password: "secret", password_confirmation: "oops" } }
        assert_select "div.new-user"
        assert_select "div#error_explanation", /Password confirmation doesn't match Password/
      end

      test "doesn't create a new user" do
        post "/users/new", params: { user: { name: "new user", email: "newuser@dafox.com", password: "secret", password_confirmation: "oops" } }
        assert_empty User.where(email: "newuser@dafox.com")
      end
    end
  end

  test "gets user details page" do
    login_as(users(:one))
    get user_url(users(:one))
    assert_response :success
    assert_select "h2.user-details-title"
    assert_select "p.name", /#{users(:one).name}/
    assert_select "p.email", /#{users(:one).email}/
    assert_select "p.created-at", /#{users(:one).created_at.localtime.to_formatted_s(:long_ordinal)}/
  end

  test "doesnt show user details for another user" do
    login_as(users(:one))
    get user_url(users(:two))
    follow_redirect!
    assert_equal "/users/#{users(:one).id}", path
    assert_equal "You cannot access information for another user", flash[:alert]
  end

  test "gets user edit page" do
    login_as(users(:one))
    get edit_user_url(users(:one))
    assert_response :success
    assert_select 'input#user_name' do
      assert_select "[value=?]", users(:one).name
    end
    assert_select 'input#user_email' do
      assert_select "[value=?]", users(:one).email
    end
  end

  test "doesnt allow edit page for a different user" do
    login_as(users(:one))
    get edit_user_url(users(:two))
    follow_redirect!
    assert_equal "/users/#{users(:one).id}/edit", path
    assert_equal "You cannot edit information for another user", flash[:alert]
  end

  test "updates user name and redirect to user details page" do
    new_user_name = "Comrade Carl"
    login_as(users(:one))
    patch "/users/#{users(:one).id}", params: { user: { name: new_user_name } }
    follow_redirect!
    assert_equal "/users/#{users(:one).id}", path
    assert_select "h2.user-details-title"
    assert_select "p.name", /#{new_user_name}/
  end

  describe "when updating email" do
    describe "for non-unique new email" do
      test "does not update email" do
        origional_email = User.find(users(:one).id).email
        login_as(users(:one))
        patch "/users/#{users(:one).id}", params: { user: { email: users(:two).email } }
        assert_equal origional_email, User.find(users(:one).id).email
      end

      test "redirects to user details page with instructions" do
        origional_email = User.find(users(:one).id).email
        login_as(users(:one))
        patch "/users/#{users(:one).id}", params: { user: { email: users(:two).email } }
        follow_redirect!

        assert_equal "/users/#{users(:one).id}/edit", path
        assert_equal "Emails must be unique, please request a password reset if you cannot access your account", flash[:alert]
        assert_select 'input#user_email' do
          assert_select "[value=?]", origional_email
        end
      end
    end

    describe "for uniqnue new email" do
      test "enqueues verification email" do
        login_as(users(:one))
        assert_enqueued_emails 0
        patch "/users/#{users(:one).id}", params: { user: { email: "carl+dev@dafox.com" } }
        assert_enqueued_emails 1
      end

      test "saves unconfirmed email and verification token to user record" do
        new_email = "carl+dev@dafox.com"
        assert_nil User.find(users(:one).id).email_verification_token
        login_as(users(:one))
        patch "/users/#{users(:one).id}", params: { user: { email: new_email } }
        assert_equal new_email, User.find(users(:one).id).unconfirmed_email
        assert_not_nil User.find(users(:one).id).email_verification_token
      end

      test "does not change user email before verification" do
        origional_email = User.find(users(:one).id).email
        login_as(users(:one))
        patch "/users/#{users(:one).id}", params: { user: { email: "carl+dev@dafox.com" } }
        assert_equal origional_email, User.find(users(:one).id).email
        assert_not_nil User.find(users(:one).id).email_verification_token
      end

      test "redirects to user details page with instructions" do
        origional_email = User.find(users(:one).id).email
        login_as(users(:one))
        patch "/users/#{users(:one).id}", params: { user: { email: "carl+dev@dafox.com" } }
        follow_redirect!
        assert_equal "Please follow the verification link sent to your new email to confirm the change", flash[:notice]
        assert_equal "/users/#{users(:one).id}", path
        assert_select "p.email", /#{origional_email}/
      end
    end
  end

  private
    def login_as(user)
      post "/login", params: { email: user.email, password: "secret" }
    end
end

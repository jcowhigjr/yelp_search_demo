require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert false
  # end

  test 'user can be created' do
    user =
      User.new(
        name: 'test',
        email: 'user@example.com',
        password: 'password',
        password_confirmation: 'password',
      )
    assert_predicate user, :valid?
  end

  test 'user cannot be created without a name' do
    user =
      User.new(
        email: 'user@example.com',
        password: 'password',
        password_confirmation: 'password',
      )
    assert_not user.valid?
  end

  test 'user cannot be created without an email' do
    user =
      User.new(
        name: 'test',
        password: 'password',
        password_confirmation: 'password',
      )
    assert_not user.valid?
  end

  test 'user cannot be created without a password' do
    user =
      User.new(
        name: 'test',
        email: 'myemail@example.com',
        password_confirmation: 'password',
      )
    assert_not user.valid?
  end

  test 'user cannot be created without a password confirmation' do
    user =
      User.new(name: 'test', email: 'myemail@example.com', password: 'password')
    assert_not user.valid?
  end

  test 'user cannot be created with a password that is too short' do
    user =
      User.new(
        name: 'test',
        email: 'myemail@example.com',
        password: 'pass',
        password_confirmation: 'pass',
      )
    assert_not user.valid?
  end

  test 'user cannot be created with a password that does not match password confirmation' do
    user =
      User.new(
        name: 'test',
        email: 'myemail@example.com',
        password: 'password',
        password_confirmation: 'password1',
      )
    assert_not user.valid?
  end

  test 'user cannot be created with an email that is not unique' do
    user =
      User.new(
        name: 'test',
        email: 'myemail@example.com',
        password: 'password',
        password_confirmation: 'password',
      ) # create a user
    user.save
    user2 =
      User.new(
        name: 'test2',
        email: 'myemail@example.com',
        password: 'password',
        password_confirmation: 'password',
      ) # try to create another user with the same email
    assert_not user2.valid?
  end
end

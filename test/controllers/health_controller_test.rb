require 'test_helper'

class HealthControllerTest < ActionDispatch::IntegrationTest
  test 'should return OK when database is healthy' do
    # Assuming the database is healthy by default in the test environment
    get healthz_url

    assert_response :ok
    assert_equal 'OK', @response.body
  end

  test 'should return service_unavailable when database execute fails with ConnectionNotEstablished' do
    # Simulate a database connection error
    error = ActiveRecord::ConnectionNotEstablished.new('Simulated connection error')
    ActiveRecord::Base.connection.stubs(:execute).raises(error)

    get healthz_url

    assert_response :service_unavailable
    assert_equal 'Service Unavailable', @response.body

    # Unstub to avoid affecting other tests
    ActiveRecord::Base.connection.unstub(:execute)
  end

  test 'should return service_unavailable when database execute fails with NoDatabaseError' do
    error = ActiveRecord::NoDatabaseError.new('Simulated no database error')
    ActiveRecord::Base.connection.stubs(:execute).raises(error)

    get healthz_url

    assert_response :service_unavailable
    assert_equal 'Service Unavailable', @response.body

    ActiveRecord::Base.connection.unstub(:execute)
  end

  test 'should return service_unavailable when database execute fails with a different ConnectionNotEstablished' do
    # This test is similar to the first failure case but ensures the stubbing logic is robust
    # for multiple execute stubs if needed, though here it's just a distinct test case.
    error = ActiveRecord::ConnectionNotEstablished.new('Simulated different execute error')
    ActiveRecord::Base.connection.stubs(:execute).raises(error)

    get healthz_url

    assert_response :service_unavailable
    assert_equal 'Service Unavailable', @response.body

    ActiveRecord::Base.connection.unstub(:execute)
  end

  test 'should return service_unavailable on unexpected StandardError during execute' do
    ActiveRecord::Base.connection.stubs(:execute).raises(StandardError.new('Simulated unexpected error'))

    get healthz_url

    assert_response :service_unavailable
    assert_equal 'Service Unavailable', @response.body

    ActiveRecord::Base.connection.unstub(:execute)
  end
end

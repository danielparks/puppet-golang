# frozen_string_literal: true

# rspec-puppet function testing makes lines too long
#
# @params *args
#   Parameters to function
# @params returns
#   Optional. The expected return value.
# @params fails
#   Optional. A string or regexp to match an expected error.
# @params block
#   Optional. Is passed the result of the check so far (with `and_return` and
#   `and_raise_error` if specified) and is expected to return the check.
#
#   ```ruby
#   runs_with('bad') { |check| check.and_raise_error(ArgumentError) }
#   ```
def runs_with(*args, returns: :nocheck, fails: :nocheck)
  check = run.with_params(*args)

  if returns != :nocheck
    check = check.and_return(returns)
  end

  if fails != :nocheck
    check = check.and_raise_error(StandardError, fails)
  end

  if block_given?
    check = yield check
  end

  is_expected.to check
end

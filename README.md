# Frame Payments Ruby Library

A Ruby library for the Frame Payments API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'frame'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install frame
```

## Usage

The library needs to be configured with your Frame API key:

```ruby
require 'frame'
Frame.api_key = 'your_api_key'
```

### Customers

Create a customer:

```ruby
customer = Frame::Customer.create(
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+12345678900',
  metadata: {
    user_id: '12345'
  }
)
```

Retrieve a customer:

```ruby
customer = Frame::Customer.retrieve('cus_123456789')
```

Update a customer:

```ruby
customer = Frame::Customer.retrieve('cus_123456789')
customer.name = 'Jane Doe'
customer.save

# Alternative approach
customer = Frame::Customer.retrieve('cus_123456789')
customer.save(name: 'Jane Doe')
```

List all customers:

```ruby
customers = Frame::Customer.list
customers.each do |customer|
  puts "Customer: #{customer.name}, Email: #{customer.email}"
end

# With pagination
customers = Frame::Customer.list(page: 1, per_page: 20)
```

Search customers:

```ruby
customers = Frame::Customer.search(name: 'John')
```

Delete a customer:

```ruby
Frame::Customer.delete('cus_123456789')
# or
customer = Frame::Customer.retrieve('cus_123456789')
customer.delete
```

Block/unblock a customer:

```ruby
customer = Frame::Customer.retrieve('cus_123456789')
customer.block

# Unblock
customer.unblock
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/frame. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/frame/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Frame project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/frame/blob/main/CODE_OF_CONDUCT.md).

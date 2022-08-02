# Clever

This is a simple Ruby API wrapper for Clever.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clever'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clever

## Usage

### Configuration
The gem can be initialized as follows:

```ruby
client = Clever::Client.configure do |config|
  config.app_id        = 'app_id for district'
  config.vendor_key    = 'vendor_key for tci'
  config.vendor_secret = 'vendor_secret for tci'
end
```
### Requests
This gem support requesting:
  - Students
  - Teachers
  - Courses
  - Sections
  - Classrooms
  - Enrollments
  - Contacts
  - Schools

#### Students
- Request all students:
  ```ruby
  client.students
  ```
- Request a subset of students, filtered by their `id`:
  ```ruby
  client.students([student_1['data']['id']], student_2['data']['id'], …])
  ```
#### Teachers
- Request all teachers:
  ```ruby
  client.teachers
  ```
- Request a subset of teachers, filtered by their `id`:
  ```ruby
  client.teachers([teacher_1['data']['id']], teacher_2['data']['id'], …])
  ```
#### Courses
- Request all courses:
  ```ruby
  client.teachers
  ```
- Request a subset of courses, filtered by their `id`:
  ```ruby
  client.courses([course_1['data']['id']], course_2['data']['id'], …])
  ```
#### Sections
- Request all sections:
  ```ruby
  client.sections
  ```
- Request a subset of sections, filtered by their `id`:
  ```ruby
  client.sections([section_1['data']['id']], section_2['data']['id'], …])
  ```
#### Classrooms
- Request all classrooms
  ```ruby
  client.classrooms
  ```
#### Enrollments
- Request all enrollments
  ```ruby
  client.enrollments
  ```
- Request a subset of enrollments, filtered by their classroom's `id`:
  ```ruby
  client.enrollments([classroom_1['data']['id'], classroom_2['data']['id']], …)
  ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/clever.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clever::Client do
  include_context 'api responses'

  it 'is configurable' do
    expect(client).to be_a(Clever::Client)
    expect(client.app_id).to eq(app_id)
    expect(client.vendor_key).to eq(vendor_key)
    expect(client.vendor_secret).to eq(vendor_secret)
  end

  it 'has proper defaults' do
    client = Clever::Client.new
    expect(client.api_url).to eq(Clever::API_URL)
    expect(client.tokens_endpoint).to eq(Clever::TOKENS_ENDPOINT)
  end

  describe 'authentication' do
    let(:mock_response) { Clever::Response.new(stub(body: tokens_body, status: status)) }
    before { client.connection.expects(:execute).with(Clever::TOKENS_ENDPOINT).returns(mock_response) }

    context 'successful authentication' do
      it 'sets app_token' do
        client.connection.expects(:set_token).with(app_token)
        client.authenticate
        expect(client.app_token).to eq(app_token)
      end
    end

    context 'connection error' do
      let(:tokens_body) { nil }
      let(:status) { 401 }
      it 'raises error' do
        expect { client.authenticate }.to raise_error(Clever::ConnectionError)
      end
    end

    context 'district not found' do
      let(:tokens_body) { { 'data' => [] } }
      it 'raises error' do
        expect { client.authenticate }.to raise_error(Clever::DistrictNotFound)
      end
    end
  end

  describe 'tokens' do
    before { client.connection.expects(:execute).with(Clever::TOKENS_ENDPOINT).returns(mock_response) }
    let(:response) { client.tokens }

    context 'unsuccessful response' do
      let(:mock_response) { Clever::Response.new(stub(body: nil, status: 401)) }

      it 'returns a failed response' do
        expect(response.success?).to eq(false)
        expect(response.status).to eq(401)
      end
    end

    context 'successful response' do
      let(:raw_body) do
        {
          'data' => [{
            'id' => '58939ac0a206f40316fe8a1c',
            'created' => '2017-02-02T20:46:56.435Z',
            'owner' => { 'type' => 'district', 'id' => '5800e1c5e16c4230146fce0' },
            'access_token' => '0ed35a0de3005aa1c77df310ac0375a6158881c4',
            'scopes' => ['read:district_admins']
          }]
        }
      end
      let(:mock_response) { Clever::Response.new(stub(body: raw_body, status: 200)) }

      it 'returns a response with the body mapped' do
        expect(response.success?).to eq(true)
        expect(response.status).to eq(200)
        expect(response.raw_body).to eq(raw_body)
        expect(response.body.size).to eq(raw_body['data'].length)
      end
    end
  end

  describe 'send_grade' do
    before do
      client.connection.expects(:execute).with(Clever::TOKENS_ENDPOINT).returns(tokens_response)
      client.connection.expects(:set_token).with(app_token)
      client.connection.expects(:execute)
        .with(Clever::GRADES_ENDPOINT, :post, nil, request_body)
        .returns(mock_response)
    end
    let(:request_body) do
      { userID: 'userId', assignmentId: 'assignmentId', scoreGiven: 1, scoreMaximum: 100 }
    end
    let(:response) { client.send_grade(request_body) }

    context 'unsuccessful response' do
      let(:mock_response) { Clever::Response.new(stub(body: nil, status: 401)) }

      it 'returns a failed response' do
        expect(response.success?).to eq(false)
        expect(response.status).to eq(401)
      end
    end

    context 'successful response' do
      let(:mock_response) { Clever::Response.new(stub(body: nil, status: 200)) }

      it 'returns a response with the body mapped' do
        expect(response.success?).to eq(true)
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'user SSO' do
    describe 'user_uid_for_code' do
      let(:code) { '1234' }

      before do
        client.connection.expects(:execute)
              .with(Clever::USER_TOKEN_ENDPOINT, :post, nil,
                    { code: code, grant_type: 'authorization_code', redirect_uri: nil })
              .returns(user_token_response)
      end

      context 'failed request' do
        let(:user_token_body) { nil }
        let(:status) { 401 }

        it 'raises error' do
          expect { client.user_uid_for_code(code) }.to raise_error(Clever::ConnectionError)
        end
      end

      context 'when the request is successful' do
        before do
          client.connection.expects(:set_token).with(app_token)
          client.connection.expects(:execute)
                .with(Clever::ME_ENDPOINT, :get)
                .returns(user_response)
        end

        it 'fetches the user ID from the /me endpoint' do
          expect(client.user_uid_for_code(code)).to eq(teacher_1['data']['id'])
        end
      end
    end
  end

  describe 'district data requests' do
    before do
      client.connection.expects(:execute).with(Clever::TOKENS_ENDPOINT).returns(tokens_response)
      client.connection.expects(:set_token).with(app_token)
    end

    describe 'students' do
      before do
        client.connection.expects(:execute)
          .with(Clever::STUDENTS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(students_response)
      end

      context 'without uids passed in' do
        it 'authenticates and returns students' do
          response = client.students
          expect(client.app_token).to eq(app_token)

          expect(response.length).to eq(3)

          first_student  = response[0]
          second_student = response[1]
          third_student = response[2]

          expect(first_student.class).to eq(Clever::Types::Student)
          expect(first_student.uid).to eq(student_1['data']['id'])
          expect(first_student.first_name).to eq(student_1['data']['name']['first'])
          expect(first_student.last_name).to eq(student_1['data']['name']['last'])
          expect(first_student.username).to eq(student_1['data']['roles']['student']['sis_id'])
          expect(first_student.provider).to eq('clever')

          expect(second_student.class).to eq(Clever::Types::Student)
          expect(second_student.uid).to eq(student_2['data']['id'])
          expect(second_student.first_name).to eq(student_2['data']['name']['first'])
          expect(second_student.last_name).to eq(student_2['data']['name']['last'])
          expect(second_student.username).to eq(student_2['data']['email'])
          expect(second_student.provider).to eq('clever')

          expect(third_student.class).to eq(Clever::Types::Student)
          expect(third_student.uid).to eq(student_3['data']['id'])
          expect(third_student.first_name).to eq(student_3['data']['name']['first'])
          expect(third_student.last_name).to eq(student_3['data']['name']['last'])
          expect(third_student.username).to eq(student_3['data']['credentials']['district_username'])
          expect(third_student.provider).to eq('clever')
        end
      end

      context 'with uids passed in' do
        it 'authenticates and returns students whose uids have been passed in' do
          response = client.students([student_1['data']['id']])

          expect(response.length).to eq(1)

          student = response[0]

          expect(student.class).to eq(Clever::Types::Student)
          expect(student.uid).to eq(student_1['data']['id'])
          expect(student.first_name).to eq(student_1['data']['name']['first'])
          expect(student.last_name).to eq(student_1['data']['name']['last'])
          expect(student.username).to eq(student_1['data']['roles']['student']['sis_id'])
          expect(student.provider).to eq('clever')
        end
      end

      context 'with username_source' do
        context 'district_username' do
          let(:username_source) { 'district_username' }
          it 'returns the proper usernames' do
            response = client.students

            expect(response.length).to eq(3)

            first_student  = response[0]
            second_student = response[1]
            third_student  = response[2]

            expect(first_student.username).to eq(student_1['data']['roles']['student']['sis_id'])
            expect(second_student.username).to eq(student_2['data']['email'])
            expect(third_student.username).to eq(student_3['data']['credentials']['district_username'])
          end
        end

        context 'email' do
          let(:username_source) { 'email' }
          it 'returns the proper usernames' do
            response = client.students

            expect(response.length).to eq(3)

            first_student  = response[0]
            second_student = response[1]
            third_student  = response[2]

            expect(first_student.username).to eq(student_1['data']['roles']['student']['sis_id'])
            expect(second_student.username).to eq(student_2['data']['email'])
            expect(third_student.username).to eq(student_3['data']['email'])
          end
        end

        context 'sis_id' do
          let(:username_source) { 'sis_id' }
          it 'returns the proper usernames' do
            response = client.students

            expect(response.length).to eq(3)

            first_student  = response[0]
            second_student = response[1]
            third_student  = response[2]

            expect(first_student.username).to eq(student_1['data']['roles']['student']['sis_id'])
            expect(second_student.username).to eq(student_2['data']['roles']['student']['sis_id'])
            expect(third_student.username).to eq(student_3['data']['credentials']['district_username'])
          end
        end
      end
    end

    describe 'admins' do
      before do
        client.connection.expects(:execute)
          .with(Clever::DISTRICT_ADMINS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(district_admins_response)

        client.connection.expects(:execute)
          .with(Clever::SCHOOL_ADMINS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(school_admins_response)
      end

      context 'without uids passed in' do
        it 'authenticates and returns teachers' do
          response = client.admins
          expect(client.app_token).to eq(app_token)

          expect(response.length).to eq(2)

          first_admin  = response[0]
          second_admin = response[1]

          expect(first_admin.class).to eq(Clever::Types::DistrictAdmin)
          expect(first_admin.uid).to eq(district_admin_1['data']['id'])
          expect(first_admin.email).to eq(district_admin_1['data']['email'])
          expect(first_admin.first_name).to eq(district_admin_1['data']['name']['first'])
          expect(first_admin.last_name).to eq(district_admin_1['data']['name']['last'])
          expect(first_admin.provider).to eq('clever')
          expect(first_admin.role).to eq('admin')

          expect(second_admin.class).to eq(Clever::Types::DistrictAdmin)
          expect(second_admin.uid).to eq(district_admin_2['data']['id'])
          expect(second_admin.email).to eq(district_admin_2['data']['email'])
          expect(second_admin.first_name).to eq(district_admin_2['data']['name']['first'])
          expect(second_admin.last_name).to eq(district_admin_2['data']['name']['last'])
          expect(second_admin.provider).to eq('clever')
          expect(second_admin.role).to eq('admin')
        end
      end

      context 'with uids passed in' do
        it 'authenticates and returns students whose uids have been passed in' do
          response = client.admins([district_admin_1['data']['id']])
          expect(client.app_token).to eq(app_token)

          expect(response.length).to eq(1)

          admin = response[0]

          expect(admin.class).to eq(Clever::Types::DistrictAdmin)
          expect(admin.uid).to eq(district_admin_1['data']['id'])
          expect(admin.email).to eq(district_admin_1['data']['email'])
          expect(admin.first_name).to eq(district_admin_1['data']['name']['first'])
          expect(admin.last_name).to eq(district_admin_1['data']['name']['last'])
          expect(admin.provider).to eq('clever')
          expect(admin.role).to eq('admin')
        end
      end

      context 'with username source' do
        context 'district_username' do
          let(:staff_username_source) { 'district_username' }

          it 'returns the proper usernames' do
            response = client.admins

            expect(response.length).to eq(2)

            first_admin  = response[0]
            second_admin = response[1]

            expect(first_admin.username).to eq(district_admin_1['data']['roles']['district_admin']['credentials']['district_username'])
            expect(second_admin.username).to be_nil
          end
        end

        context 'district_username' do
          let(:staff_username_source) { 'email' }

          it 'returns the proper usernames' do
            response = client.admins

            expect(response.length).to eq(2)

            first_admin  = response[0]
            second_admin = response[1]

            expect(first_admin.username).to eq(district_admin_1['data']['email'])
            expect(second_admin.username).to eq(district_admin_2['data']['email'])
          end
        end

        context 'district_username' do
          let(:staff_username_source) { 'sis_id' }

          it 'returns the proper usernames' do
            response = client.admins

            expect(response.length).to eq(2)

            first_admin  = response[0]
            second_admin = response[1]

            expect(first_admin.username).to eq(district_admin_1['data']['roles']['district_admin']['sis_id'])
            expect(second_admin.username).to eq(nil)
          end
        end
      end
    end

    describe 'teachers' do
      before do
        client.connection.expects(:execute)
          .with(Clever::TEACHERS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(teachers_response)
      end

      context 'without uids passed in' do
        it 'authenticates and returns teachers' do
          response = client.teachers
          expect(client.app_token).to eq(app_token)

          expect(response.length).to eq(2)

          first_teacher  = response[0]
          second_teacher = response[1]

          expect(first_teacher.class).to eq(Clever::Types::Teacher)
          expect(first_teacher.uid).to eq(teacher_1['data']['id'])
          expect(first_teacher.email).to eq(teacher_1['data']['email'])
          expect(first_teacher.first_name).to eq(teacher_1['data']['name']['first'])
          expect(first_teacher.last_name).to eq(teacher_1['data']['name']['last'])
          expect(first_teacher.provider).to eq('clever')
          expect(first_teacher.role).to eq('teacher')

          expect(second_teacher.class).to eq(Clever::Types::Teacher)
          expect(second_teacher.uid).to eq(teacher_2['data']['id'])
          expect(second_teacher.email).to eq(teacher_2['data']['email'])
          expect(second_teacher.first_name).to eq(teacher_2['data']['name']['first'])
          expect(second_teacher.last_name).to eq(teacher_2['data']['name']['last'])
          expect(second_teacher.provider).to eq('clever')
          expect(second_teacher.role).to eq('teacher')
        end
      end

      context 'with uids passed in' do
        it 'authenticates and returns students whose uids have been passed in' do
          response = client.teachers([teacher_1['data']['id']])
          expect(client.app_token).to eq(app_token)

          expect(response.length).to eq(1)

          teacher = response[0]

          expect(teacher.class).to eq(Clever::Types::Teacher)
          expect(teacher.uid).to eq(teacher_1['data']['id'])
          expect(teacher.email).to eq(teacher_1['data']['email'])
          expect(teacher.first_name).to eq(teacher_1['data']['name']['first'])
          expect(teacher.last_name).to eq(teacher_1['data']['name']['last'])
          expect(teacher.provider).to eq('clever')
          expect(teacher.role).to eq('teacher')
        end
      end

      context 'with username source' do
        context 'district_username' do
          let(:staff_username_source) { 'district_username' }

          it 'returns the proper usernames' do
            response = client.teachers

            expect(response.length).to eq(2)

            first_teacher  = response[0]
            second_teacher = response[1]

            expect(first_teacher.username).to eq(teacher_1['data']['roles']['teacher']['credentials']['district_username'])
            expect(second_teacher.username).to be_nil
          end
        end

        context 'district_username' do
          let(:staff_username_source) { 'email' }

          it 'returns the proper usernames' do
            response = client.teachers

            expect(response.length).to eq(2)

            first_teacher  = response[0]
            second_teacher = response[1]

            expect(first_teacher.username).to eq(teacher_1['data']['email'])
            expect(second_teacher.username).to eq(teacher_2['data']['email'])
          end
        end

        context 'district_username' do
          let(:staff_username_source) { 'sis_id' }

          it 'returns the proper usernames' do
            response = client.teachers

            expect(response.length).to eq(2)

            first_teacher  = response[0]
            second_teacher = response[1]

            expect(first_teacher.username).to eq(teacher_1['data']['roles']['teacher']['sis_id'])
            expect(second_teacher.username).to eq(nil)
          end
        end
      end
    end

    describe 'courses' do
      before do
        client.connection.expects(:execute)
          .with(Clever::COURSES_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(courses_response)
      end

      it 'authenticates and returns courses' do
        response = client.courses
        expect(client.app_token).to eq(app_token)

        first_course  = response[0]
        second_course = response[1]

        expect(first_course.class).to eq(Clever::Types::Course)
        expect(first_course.uid).to eq(course_1['data']['id'])
        expect(first_course.district).to eq(course_1['data']['district'])
        expect(first_course.name).to eq(course_1['data']['name'])
        expect(first_course.number).to eq(course_1['data']['number'])

        expect(second_course.class).to eq(Clever::Types::Course)
        expect(second_course.uid).to eq(course_2['data']['id'])
        expect(second_course.district).to eq(course_2['data']['district'])
        expect(second_course.name).to eq(course_2['data']['name'])
        expect(second_course.number).to eq(course_2['data']['number'])
      end
    end

    describe 'sections' do
      before do
        client.connection.expects(:execute)
          .with(Clever::SECTIONS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(sections_response)
      end

      it 'authenticates and returns sections' do
        response = client.sections
        expect(client.app_token).to eq(app_token)

        first_section  = response[0]
        second_section = response[1]

        expect(first_section.class).to eq(Clever::Types::Section)
        expect(first_section.uid).to eq(section_1['data']['id'])
        expect(first_section.name).to eq(section_1['data']['name'])
        expect(first_section.grades).to eq([section_1['data']['grade']])
        expect(first_section.period).to eq(section_1['data']['period'])
        expect(first_section.course).to eq(section_1['data']['course'])
        expect(first_section.subjects).to eq([section_1['data']['subject']])
        expect(first_section.teachers).to eq(section_1['data']['teachers'])
        expect(first_section.students).to eq(section_1['data']['students'])
        expect(first_section.provider).to eq('clever')
        expect(first_section.primary_teacher_uid).to eq(section_1['data']['teacher'])

        expect(second_section.class).to eq(Clever::Types::Section)
        expect(second_section.uid).to eq(section_2['data']['id'])
        expect(second_section.name).to eq(section_2['data']['name'])
        expect(second_section.grades).to eq([section_2['data']['grade']])
        expect(second_section.period).to eq(section_2['data']['period'])
        expect(second_section.course).to eq(section_2['data']['course'])
        expect(second_section.subjects).to eq([])
        expect(second_section.teachers).to eq(section_2['data']['teachers'])
        expect(second_section.students).to eq(section_2['data']['students'])
        expect(second_section.provider).to eq('clever')
        expect(second_section.primary_teacher_uid).to eq(section_2['data']['teacher'])
      end
    end

    describe 'terms' do
      before do
        client.connection.expects(:execute)
          .with(Clever::TERMS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(terms_response)
      end

      it 'authenticates and returns terms for district' do
        response = client.terms
        expect(client.app_token).to eq(app_token)

        first_term = response[0]

        expect(first_term.class).to eq(Clever::Types::Term)
        expect(first_term.uid).to eq('1')
        expect(first_term.name).to eq('term name')
        expect(first_term.start_date).to eq('2019-08-21')
        expect(first_term.end_date).to eq('2020-01-10')
      end
    end

    describe 'classrooms' do
      before do
        client.connection.expects(:execute)
          .with(Clever::COURSES_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(courses_response)
        client.connection.expects(:execute)
          .with(Clever::TERMS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(terms_response)
        client.connection.expects(:execute)
          .with(Clever::SECTIONS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(sections_response)
      end

      it 'authenticates and returns classrooms with properly mapped course numbers' do
        response = client.classrooms
        expect(client.app_token).to eq(app_token)

        first_classroom = response[0]
        second_classroom = response[1]

        expect(first_classroom.class).to eq(Clever::Types::Classroom)
        expect(first_classroom.uid).to eq(section_1['data']['id'])
        expect(first_classroom.name).to eq(section_1['data']['name'])
        expect(first_classroom.period).to eq(section_1['data']['period'])
        expect(first_classroom.course_number).to eq(course_1['data']['number'])
        expect(first_classroom.grades).to eq([section_1['data']['grade']])
        expect(first_classroom.subjects).to eq([section_1['data']['subject']])
        expect(first_classroom.term_name).to eq('term name')
        expect(first_classroom.term_start_date).to eq('2019-08-21')
        expect(first_classroom.term_end_date).to eq('2020-01-10')
        expect(first_classroom.provider).to eq('clever')

        expect(second_classroom.class).to eq(Clever::Types::Classroom)
        expect(second_classroom.uid).to eq(section_2['data']['id'])
        expect(second_classroom.name).to eq(section_2['data']['name'])
        expect(second_classroom.period).to eq(section_2['data']['period'])
        expect(second_classroom.course_number).to eq(nil)
        expect(second_classroom.grades).to eq([section_2['data']['grade']])
        expect(second_classroom.subjects).to eq([])
        expect(second_classroom.provider).to eq('clever')
      end
    end

    describe 'enrollments' do
      before do
        client.connection.expects(:execute)
          .with(Clever::SECTIONS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(sections_response)
      end

      context 'without classroom_uids passed in' do
        it 'authenticates and returns enrollments for primary teachers and students' do
          response = client.enrollments
          expect(client.app_token).to eq(app_token)

          student_enrollments = response[:student].each_with_object({}) do |enrollment, enrollments|
            enrollments[enrollment.classroom_uid] ||= []
            enrollments[enrollment.classroom_uid] << [enrollment.user_uid, enrollment.primary]
          end

          teacher_enrollments = response[:teacher].each_with_object({}) do |enrollment, enrollments|
            enrollments[enrollment.classroom_uid] ||= []
            enrollments[enrollment.classroom_uid] << [enrollment.user_uid, enrollment.primary]
          end

          expect(student_enrollments['5']).to contain_exactly(['6', false], ['7', false], ['8', false])
          expect(student_enrollments['20']).to contain_exactly(['1', false], ['2', false], ['3', false])

          expect(teacher_enrollments['5']).to contain_exactly(['5', false], ['2', true])
          expect(teacher_enrollments['20']).to contain_exactly(['6', true])
        end
      end

      context 'with classroom_uids passed in' do
        it 'authenticates and returns enrollments for sections in classroom_uids' do
          response = client.enrollments([section_1['data']['id']])
          expect(client.app_token).to eq(app_token)

          student_enrollments = response[:student].each_with_object({}) do |enrollment, enrollments|
            enrollments[enrollment.classroom_uid] ||= []
            enrollments[enrollment.classroom_uid] << enrollment.user_uid
          end

          teacher_enrollments = response[:teacher].each_with_object({}) do |enrollment, enrollments|
            enrollments[enrollment.classroom_uid] ||= []
            enrollments[enrollment.classroom_uid] << enrollment.user_uid
          end

          expect(student_enrollments['5']).to eq(%w(6 7 8))
          expect(teacher_enrollments['5']).to eq(%w(5 2))

          expect(student_enrollments['20']).to be_nil
          expect(teacher_enrollments['20']).to be_nil
        end
      end
    end

    describe 'most_recent_event' do
      before do
        client.connection.expects(:execute)
          .with("#{Clever::EVENTS_ENDPOINT}?ending_before=last&limit=1")
          .returns(most_recent_event_response)
      end

      context 'when event is a type with a mapping' do
        it 'returns the event properly' do
          response = client.most_recent_event
          expect(response).to be_a(Clever::Types::Event)
          expect(response.provider).to eq('clever')
          expect(response.uid).to eq(event_1['data']['id'])
          expect(response.type).to eq('students')
          expect(response.action).to eq('created')
          expect(response.object).to be_a(Clever::Types::Student)
        end
      end

      context 'when event is a type without a mapping' do
        let(:most_recent_event_body) { { 'data' => [event_7] } }
        it 'returns an event with a nil object' do
          response = client.most_recent_event
          expect(response).to be_a(Clever::Types::Event)
          expect(response.provider).to eq('clever')
          expect(response.uid).to eq(event_7['data']['id'])
          expect(response.type).to eq('studentcontacts')
          expect(response.action).to eq('created')
          expect(response.object).to be_nil
        end
      end

      context 'when no events are present' do
        let(:most_recent_event_body) { { 'data' => [] } }
        it 'returns nil' do
          expect(client.most_recent_event).to be_nil
        end
      end
    end

    describe 'events' do
      let(:starting_after) { '12345' }
      before do
        client.connection.expects(:execute)
          .with("#{Clever::EVENTS_ENDPOINT}?starting_after=#{starting_after}", :get, limit: Clever::PAGE_LIMIT)
          .returns(events_response)
      end

      context 'when no events present' do
        let(:events_body) { { 'data' => [] } }
        it 'returns an empty array' do
          expect(client.events(starting_after)).to eq([])
        end
      end

      context 'when events present' do
        it 'only returns the desired event types' do
          response = client.events(starting_after)
          expect(response.length).to eq(3)

          student_created_response = response[0]
          teacher_updated_response = response[1]
          section_deleted_response = response[2]

          expect(student_created_response.uid).to eq(event_1['data']['id'])
          expect(student_created_response.type).to eq('students')
          expect(student_created_response.action).to eq('created')
          expect(student_created_response.provider).to eq('clever')

          expect(teacher_updated_response.uid).to eq(event_2['data']['id'])
          expect(teacher_updated_response.type).to eq('teachers')
          expect(teacher_updated_response.action).to eq('updated')
          expect(teacher_updated_response.provider).to eq('clever')

          expect(section_deleted_response.uid).to eq(event_3['data']['id'])
          expect(section_deleted_response.type).to eq('sections')
          expect(section_deleted_response.action).to eq('deleted')
          expect(section_deleted_response.provider).to eq('clever')

          expect(response.map(&:type).all? { |type| Clever::EVENT_TYPES.include?(type) }).to eq(true)
        end
      end
    end
  end

  describe 'types .to_h' do
    context 'teacher' do
      it 'serializes the expected fields' do
        teacher = Clever::Types::Teacher.new(teacher_1['data'])
        expect(teacher.to_h).to eq(
          uid: teacher_1['data']['id'],
          username: nil, # username is nil because there is no client
          email: teacher_1['data']['email'],
          first_name: teacher_1['data']['name']['first'],
          last_name: teacher_1['data']['name']['last'],
          provider: 'clever',
          legacy_id: 'legacy_id'
        )
      end
    end

    context 'student' do
      it 'serializes the expected fields' do
        student = Clever::Types::Student.new(student_1['data'])
        expect(student.to_h).to eq(
          uid: student_1['data']['id'],
          first_name: student_1['data']['name']['first'],
          last_name: student_1['data']['name']['last'],
          username: student_1['data']['roles']['student']['sis_id'],
          provider: 'clever'
        )
      end
    end
  end
end

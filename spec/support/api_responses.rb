# frozen_string_literal: true

RSpec.shared_context 'api responses' do
  ##################################### TOKENS RESPONSE #####################################
  let(:tokens_body) do
    {
      'data' => [{
        'id' => '58939ac0a206f40316fe8a1c',
        'created' => '2017-02-02T20:46:56.435Z',
        'owner' => { 'type' => 'district', 'id' => app_id },
        'access_token' => app_token,
        'scopes' => ['read:district_admins']
      }]
    }
  end
  let(:tokens_response) { Clever::Response.new(stub(body: tokens_body, status: status)) }

  #################################### STUDENTS RESPONSE ####################################
  let(:student_1) do
    {
      'data' => {
        'id' => '17b6cc35f',
        'name' => { 'first' => 'jane', 'last' => 'doe' },
        'credentials' => { 'district_username' => 'jdoez' },
        'grade' => '1'
      }
    }
  end
  let(:student_2) do
    {
      'data' => {
        'id' => '5b1f7442',
        'name' => { 'first' => 'johnny', 'last' => 'appleseed' },
        'credentials' => { 'district_username' => 'applej0n' },
        'grade' => '6'
      }
    }
  end
  let(:students_body) { { 'data' => [student_1, student_2] } }
  let(:students_response) { Clever::Response.new(stub(body: students_body, status: status)) }

  #################################### COURSES RESPONSE #####################################
  let(:course_1) do
    {
      'data' => {
        'id' => '1',
        'district' => '12345',
        'name' => 'The Best Course',
        'number' => '555'
      }
    }
  end
  let(:course_2) do
    {
      'data' => {
        'id' => '100',
        'district' => '12345',
        'name' => 'The Worst Course',
        'number' => '000'
      }
    }
  end
  let(:courses_body) { { 'data' => [course_1, course_2] } }
  let(:courses_response) { Clever::Response.new(stub(body: courses_body, status: status)) }

  #################################### TEACHERS RESPONSE ####################################
  let(:teacher_1) do
    {
      'data' => {
        'id' => '1',
        'email' => '12345',
        'name' => { 'first' => 'jill', 'last' => 'epstein' }
      }
    }
  end
  let(:teacher_2) do
    {
      'data' => {
        'id' => '9',
        'email' => '12345',
        'name' => { 'first' => 'darren', 'last' => 'piper' }
      }
    }
  end
  let(:teachers_body) { { 'data' => [teacher_1, teacher_2] } }
  let(:teachers_response) { Clever::Response.new(stub(body: teachers_body, status: status)) }

  #################################### SECTIONS RESPONSE ####################################
  let(:section_1) do
      {
        'data' => {
          'id' => '5',
          'name' => 'Social Studies Grade Five',
          'period' => '01',
          'grade' => '5',
          'course' => '1'
        }
      }
    end
  let(:section_2) do
    {
      'data' => {
        'id' => '20',
        'name' => 'Science Grade 1',
        'period' => '06',
        'grade' => '1',
        'course' => '1000'
      }
    }
  end
  let(:sections_body) { { 'data' => [section_1, section_2] } }
  let(:sections_response) { Clever::Response.new(stub(body: sections_body, status: status)) }
end

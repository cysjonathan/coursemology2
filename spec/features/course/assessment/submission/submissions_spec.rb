# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Course: Assessment: Submissions: Submissions' do
  let(:instance) { Instance.default }

  with_tenant(:instance) do
    let(:course) { create(:course) }
    let(:assessment) { create(:assessment, :with_all_question_types, course: course) }
    before { login_as(user, scope: :user) }

    let(:students) { create_list(:course_student, 3, course: course) }
    let(:phantom_student) { create(:course_student, :phantom, course: course) }
    let!(:submitted_submission) do
      create(:course_assessment_submission, :submitted, assessment: assessment,
                                                        course: course,
                                                        creator: students[0].user)
    end
    let!(:attempting_submission) do
      create(:course_assessment_submission, :attempting, assessment: assessment,
                                                         course: course,
                                                         creator: students[1].user)
    end
    let!(:published_submission) do
      create(:course_assessment_submission, :published, assessment: assessment,
                                                     course: course,
                                                     creator: students[2].user)
    end

    context 'As a Course Staff' do
      let(:course_staff) { create(:course_manager, course: course) }
      let(:user) { course_staff.user }
      let(:group_student) do
        # Create a group and add staff and student to group
        group = create(:course_group, course: course)
        create(:course_group_manager, course: course, group: group, course_user: course_staff)
        create(:course_group_student, course: course, group: group, course_user: students.sample)
      end

      scenario 'I can view all submissions of an assessment' do
        phantom_student
        group_student
        visit course_assessment_submissions_path(course, assessment)

        expect(page).
          to have_text(I18n.t('course.assessment.submission.submissions.index.student_header'))
        expect(page).
          to have_text(I18n.t('course.assessment.submission.submissions.index.my_student_header'))
        expect(page).
          to have_text(I18n.t('course.assessment.submission.submissions.index.other_header'))

        [submitted_submission, attempting_submission, published_submission].each do |submission|
          within all(content_tag_selector(submission)).last do
            expect(page).
              to have_text(submission.class.human_attribute_name(submission.workflow_state))
            expect(page).to have_text(submission.points_awarded)
          end
        end

        # Phantom student did not attempt submissions
        expect(page).to have_tag('tr.no-submission', count: 1)
      end
    end
  end
end

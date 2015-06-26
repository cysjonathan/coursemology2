class Course::LessonPlanItemsController < Course::ComponentController
  before_action :load_lesson_plan_items, only: [:index]
  load_and_authorize_resource :lesson_plan_item,
                              through: :course,
                              class: Course::LessonPlanItem.name
  add_breadcrumb :index, :course_lesson_plan_path

  def index #:nodoc:
  end

  private

  # Before the lesson plan is displayed, lesson plan items are ordered by start
  # date and divided into groups separated by milestones. Each group, possibly
  # except the first, is an array that has a milestone as its first item.
  # This method assigns the list of groups to @lesson_plan_items.
  def load_lesson_plan_items
    @lesson_plan_items = @course.grouped_lesson_plan_items_with_milestones
  end
end
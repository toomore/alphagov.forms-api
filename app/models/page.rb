class Page < ApplicationRecord
  has_paper_trail

  belongs_to :form
  acts_as_list scope: :form

  ANSWER_TYPES = %w[number address date email national_insurance_number phone_number selection organisation_name text name].freeze

  validates :question_text, presence: true
  validates :answer_type, presence: true, inclusion: { in: ANSWER_TYPES }

  def destroy_and_update_form!
    form = self.form
    destroy! && form.update!(question_section_completed: false)
  end

  def save_and_update_form
    save && form.update!(question_section_completed: false)
  end

  def next_page
    lower_item&.id
  end

  def as_json(options = {})
    options[:except] ||= [:next_page]
    options[:methods] ||= [:next_page]
    super(options)
  end
end

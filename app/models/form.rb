class Form < ApplicationRecord
  has_paper_trail

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy
  has_many :made_live_forms, dependent: :destroy

  validates :org, :name, presence: true
  def start_page
    pages&.first&.id
  end

  def make_live!(live_at = nil)
    live_at ||= Time.zone.now
    touch(time: live_at)

    form_blob = snapshot(live_at:)
    made_live_forms.create!(json_form_blob: form_blob.to_json, created_at: live_at)
  end

  def has_draft_version
    return true if made_live_forms.blank?

    updated_at > live_at
  end

  def draft_version
    snapshot.to_json
  end

  def live_at
    return made_live_forms.last.created_at if made_live_forms.present?
  end

  def has_live_version
    made_live_forms.present?
  end

  def live_version
    return draft_version if made_live_forms.blank?

    made_live_forms.last.json_form_blob
  end

  def name=(val)
    super(val)
    self[:form_slug] = name.parameterize
  end

  def as_json(options = {})
    options[:methods] ||= %i[live_at start_page has_draft_version has_live_version]
    super(options)
  end

  def snapshot(**kwargs)
    # override methods so it doesn't include things we don't want
    as_json(include: [:pages], methods: [:start_page]).merge(kwargs)
  end

  # form_slug is always set based on name. This is here to allow Form
  # attributes to be updated easily based on json, without changning the value in the DB
  def form_slug=(slug); end
end

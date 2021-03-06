# frozen_string_literal: true

class GraduationNewsItem
  include UserSystem

  def initialize(graduation)
    @graduation = graduation
  end

  def id
    @graduation.id
  end

  def title
    I18n.t('graduation_title', name: @graduation.group.name)
  end

  def creator; end

  def publish_at
    @graduation.start_at
  end

  def expire_at
    @graduation.end_at
  end

  def publication_state
    NewsItem::PublicationState::PUBLISHED
  end

  def persisted?
    false
  end

  def summary
    summary = +''
    if (censor = @graduation.censors.find { |c| c.member == current_user.member })
      summary << (censor.examiner? ? "Du er examinator.\n" : "Du er sensor.\n")
    end
    summary
  end

  def body
    "<a href='/graduations/#{id}'>Les mer...</a>" if @graduation.admin?
  end

  def to_model
    @graduation.to_model
  end
end

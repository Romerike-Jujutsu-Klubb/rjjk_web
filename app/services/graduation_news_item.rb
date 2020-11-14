# frozen_string_literal: true

class GraduationNewsItem
  def initialize(graduation)
    @graduation = graduation
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

  def summary; end

  def body
    @graduation.admin? ? '' : nil
  end
end

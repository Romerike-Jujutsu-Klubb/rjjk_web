# frozen_string_literal: true

class GraduationEvent
  def initialize(graduation)
    @graduation = graduation
  end

  def id
    @graduation.id
  end

  def to_model
    @graduation.to_model
  end

  def persisted?
    @graduation.persisted?
  end

  def name
    I18n.t('graduation_title', name: @graduation.group.name)
  end

  def title
    name
  end

  def start_at
    @graduation.start_at
  end

  def end_at
    @graduation.end_at
  end

  def size
    @graduation.size
  end

  def attendees
    invited_users
  end

  def invited_users
    (@graduation.graduates.select { |g| g.passed || g.passed.nil? } + @graduation.censors)
        .map(&:member).map(&:user)
  end

  def confirmed_users
    (@graduation.graduates.select { |g| g.passed || g.passed.nil? } + @graduation.censors)
        .select(&:confirmed?).map(&:member).map(&:user)
  end

  def declined_users
    @graduation.graduates.select(&:declined)
  end

  def description
    name
  end

  def ingress
    nil
  end

  def body
    @graduation.admin? ? '' : nil
  end
end

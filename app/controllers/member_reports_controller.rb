# frozen_string_literal: true

class MemberReportsController < ApplicationController
  def index
    @date = if params[:year] && params[:month]
              Date.new(params[:year].to_i, params[:month].to_i, 1)
            else
              Date.current.beginning_of_month
            end
    @year = @date.year
    @month = @date.month
    @first_date = @date.beginning_of_month
    @last_date = @date.end_of_month
    @members_before = Member.active(@first_date - 1).to_a
    @members_after = Member.active(@last_date).to_a
    @members_in = @members_after - @members_before
    @members_out = @members_before - @members_after
  end

  def history_graph_data
    timestamp = Member.maximum(:updated_at).strftime('%F_%T.%N')
    json_data = Rails.cache.fetch("member_reports/history_graph_data/#{timestamp}") do
      data, dates = MemberHistoryGraph.data_set
      expanded_data = data.map do |name, (values, color)|
        { name: name, data: Hash[dates.zip(values)], color: color }
      end
      expanded_data.to_json
    end

    render json: json_data
  end

  def grade_history_graph; end

  def grade_history_graph_data
    opts = { interval: params[:interval]&.to_i&.days, step: params[:step].try(:to_i).try(:days),
             percentage: params[:percentage].try(:to_i) }
    timestamp = [Attendance, Graduate, Member].map { |c| c.maximum(:updated_at) }.max.strftime('%F_%T.%N')
    cache_key = "member_reports/grade_history_graph_data/#{opts.hash}/#{timestamp}"
    json_data = Rails.cache.fetch(cache_key) do
      data, dates, _percentage = MemberGradeHistoryGraph.new.data_set(opts)
      expanded_data = data.map do |rank, values|
        { name: rank.name, data: Hash[dates.zip(values)] }
      end
      expanded_data.reverse.to_json
    end

    render json: json_data
  end

  def grades_graph_data
    timestamp = [Attendance, Graduate, Member].map { |c| c.maximum(:updated_at) }.max.strftime('%F_%T.%N')
    cache_key = "member_reports/grades_graph_data/#{timestamp}"
    json_data = Rails.cache.fetch(cache_key) do
      data, _dates, _percentage = MemberGradeHistoryGraph.new.ranks
      ranks = data.keys.reverse
      colors = %i[yellow orange green blue brown grey #444444 black].reverse
      expanded_data = []
      data.to_a.reverse_each.with_index do |(rank, values), i|
        expanded_data << {
          name: "#{rank.name} Left",
          data: ranks.map { |r| [r.name, r == rank ? -values[0] : 0] },
          color: colors[i],
        }
        expanded_data << {
          name: "#{rank.name} Right",
          data: ranks.map { |r| [r.name, r == rank ? values[0] : 0] },
          color: colors[i],
        }
      end
      expanded_data.to_json
    end

    render json: json_data
  end

  def age_chart; end

  def age_chart_data
    timestamp = Member.maximum(:updated_at).strftime('%F_%T.%N')
    json_data = Rails.cache.fetch("member_reports/age_chart_data/#{timestamp}") do
      age_data, age_groups = MemberAgeChart.data_set
      expanded_data = Hash[age_groups.zip(age_data).map { |group, value| [group.to_s, value] }]
      expanded_data.to_json
    end

    render json: json_data
  end
end

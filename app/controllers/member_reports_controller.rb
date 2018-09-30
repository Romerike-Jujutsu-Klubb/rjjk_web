# frozen_string_literal: true

class MemberReportsController < ApplicationController
  caches_page :age_chart, :history_graph, :grade_history_graph, :grade_history_graph_percentage

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

  def history_graph
    args = if params[:id] && params[:id].to_i <= 1280
             if /^\d+x\d+$/.match?(params[:id])
               [params[:id]]
             else
               [params[:id].to_i]
             end
           else
             []
           end
    g = MemberHistoryGraph.history_graph(*args)
    send_data(g, disposition: 'inline', type: 'image/png', filename: 'RJJK_Medlemshistorikk.png')
  end

  def grade_history_graph
    g = if params[:id] && params[:id].to_i <= 1280
          MemberGradeHistoryGraph.new.history_graph size: params[:id].to_i,
                                                    interval: params[:interval]&.to_i&.days,
                                                    step: params[:step].try(:to_i).try(:days),
                                                    percentage: params[:percentage].try(:to_i)
        else
          MemberGradeHistoryGraph.new.history_graph
        end
    send_data(g, disposition: 'inline', type: 'image/png', filename: 'RJJK_MedlemsGradsHistorikk.png')
  end

  def grade_history_graph_percentage
    grade_history_graph
  end

  def age_chart
    g = if params[:id] && params[:id].to_i <= 1280
          MemberAgeChart.chart params[:id].to_i
        else
          MemberAgeChart.chart
        end
    send_data(g, disposition: 'inline', type: 'image/png', filename: 'RJJK_Aldersfordeling.png')
  end
end

# frozen_string_literal: true

class ImsController < ApplicationController
  def index; end

  def import
    if (file = params[:file])
      imported_items ||= load_imported_items(file)
    end
    redirect_to ims_index_path, notice: "Filen er importert: #{imported_items&.size.to_i}"
  end

  private

  def open_spreadsheet
    file = params[:file]
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def load_imported_items(file)
    spreadsheet = Roo::Spreadsheet.open(file)
    rows = []
    (21..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      break if row[0].blank?

      rows << { name: row[2] }
    end
    rows
  end
end

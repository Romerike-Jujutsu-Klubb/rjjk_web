#!/usr/bin/ruby -w

reports = []
 (1..4).each do |index|
  report = File.readlines("Medlemsliste_#{index}.xml").join("\n")
  
  reports[index] = report.scan(/<(?:ss:)?Row>.*?<\/(?:ss:)?Row>/m).map do |xml_row|cells = xml_row.scan(/<ss:Cell>\s*?<ss:Data ss:Type=".*?">\s*?(.*?)\s*?<\/ss:Data>\s*?<\/ss:Cell>/m)
    cells.map {|cell| cell[0].strip}
  end
  reports[index].shift
end

p reports

raise "oops" if reports.find {|report| report && report.size != reports[1].size}

puts "reports: #{reports.size-1}"
puts "rows: #{reports[1].size}"

reports[1].each_with_index do |row, index|
  member = Member.find_by_cms_contract_id(row[0])
  member = Member.new if member.nil?
  member.update_attributes(
                           :first_name => reports[3][index][7].split(' ')[1..-1].join(' '),
  :last_name => reports[3][index][7].split(' ').first,
  :senior => (reports[3][index][3].empty? ? true : ((Date.today - Date.strptime(reports[3][index][3], '%d-%m-%Y')) / 365) > 15),
  :email => '',
  :phone_mobile => '',
  :phone_home => '',
  :phone_work => '',
  :phone_parent => '',
  :birtdate => (reports[3][index][3].empty? ? nil : Date.strptime(reports[3][index][3], '%d-%m-%Y')),
  :male => true,
  :joined_on => Date.strptime(row[1], '%d-%m-%Y'),
  :contract_id => '',
  :department => '',
  :cms_contract_id => row[0],
  :left_on => (row[2].empty? ? nil : Date.strptime(row[2], '%d-%m-%Y')),
  :parent_name => '',
  :address => '',
  :postal_code => '',
  :billing_type => '',
  :billing_name => '',
  :billing_address => '',
  :billing_postal_code => '',
  :payment_problem => '',
  :comment => '',
  :instructor => '',
  :nkf_fee => ''
  )
  member.save!
end